#!/usr/bin/env python3
import sys, os, zipfile, subprocess, tarfile, io, shutil

def extract_opengapps_zip(zip_path, target_system_dir):
    os.makedirs(target_system_dir, exist_ok=True)
    zf = zipfile.ZipFile(zip_path)
    for name in zf.namelist():
        if name.endswith('.tar.lz') or name.endswith('.tar.xz'):
            data = zf.read(name)
            if name.endswith('.tar.lz'):
                p = subprocess.Popen(['lzip', '-d'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                tar_bytes, err = p.communicate(data)
                if p.returncode != 0:
                    continue
            else:
                p = subprocess.Popen(['xz', '-d'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                tar_bytes, err = p.communicate(data)
                if p.returncode != 0:
                    continue
            try:
                tf = tarfile.open(fileobj=io.BytesIO(tar_bytes))
                for member in tf.getmembers():
                    if not member.isfile():
                        continue
                    parts = member.name.split('/')
                    for rel in ['app', 'priv-app', 'etc', 'framework']:
                        if rel in parts:
                            idx = parts.index(rel)
                            rel_path = '/'.join(parts[idx:])
                            out_path = os.path.join(target_system_dir, rel_path)
                            os.makedirs(os.path.dirname(out_path), exist_ok=True)
                            f = tf.extractfile(member)
                            with open(out_path, 'wb') as out_f:
                                shutil.copyfileobj(f, out_f)
                            break
            except Exception as e:
                print(f"Warning extracting {name}: {e}")

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: extract_opengapps_zip.py <path_to_opengapps.zip> <output_system_dir>")
        sys.exit(1)
    extract_opengapps_zip(sys.argv[1], sys.argv[2])
    print("Done unpacking OpenGApps zip.")
