#!/usr/bin/env python3
"""Wrap a plain Android boot/recovery image for the ZTE B760H (MT8127) LK.

AOSP does not honour BOARD_CUSTOM_BOOTIMG_MK (that is a LineageOS-only hook),
so images built by the AOSP workflow are plain "ANDROID!" images and the
MTK bootloader rejects them -> endless preloader/DRAM-calibration reboot loop.

This does what configs/helpers/bootimg.mk does:
  * 512-byte MTK header (0x58881688, size, name, 0xFF pad) before kernel/ramdisk
  * 96-byte ZTE header prepended to the whole image

Usage: wrap_mtk_bootimg.py <boot|recovery> <in.img> <out.img> [header.bin]
Idempotent: an image that already carries the ZTE header is copied as-is.
"""
import hashlib
import os
import struct
import sys

MTK_MAGIC = b"\x88\x16\x88\x58"
ZTE_HDR_LEN = 96


def pad(data, page):
    r = len(data) % page
    return data if r == 0 else data + b"\0" * (page - r)


def mtk_hdr(size, name):
    return struct.pack("<4sI32s472s", MTK_MAGIC, size, name, b"\xff" * 472)


def parse(img):
    assert img[:8] == b"ANDROID!", "not a plain Android boot image"
    (ksz, kaddr, rsz, raddr, ssz, saddr, taddr, page, dtsz, osver) = struct.unpack("<10I", img[8:48])
    name = img[48:64]
    cmdline = img[64:576]
    extra = img[608:1632]
    off = page
    kernel = img[off:off + ksz]
    off += len(pad(kernel, page))
    ramdisk = img[off:off + rsz]
    off += len(pad(ramdisk, page))
    second = img[off:off + ssz]
    off += len(pad(second, page))
    dt = img[off:off + dtsz]
    return dict(kaddr=kaddr, raddr=raddr, saddr=saddr, taddr=taddr, page=page,
                osver=osver, name=name, cmdline=cmdline, extra=extra,
                kernel=kernel, ramdisk=ramdisk, second=second, dt=dt)


def build(p):
    page = p["page"]
    sha = hashlib.sha1()
    for blob in (p["kernel"], p["ramdisk"], p["second"]):
        sha.update(blob)
        sha.update(struct.pack("<I", len(blob)))
    if p["dt"]:
        sha.update(p["dt"])
        sha.update(struct.pack("<I", len(p["dt"])))
    ident = sha.digest().ljust(32, b"\0")
    hdr = b"ANDROID!" + struct.pack(
        "<10I", len(p["kernel"]), p["kaddr"], len(p["ramdisk"]), p["raddr"],
        len(p["second"]), p["saddr"], p["taddr"], page, len(p["dt"]), p["osver"])
    hdr += p["name"] + p["cmdline"] + ident + p["extra"]
    out = pad(hdr, page)
    for blob in (p["kernel"], p["ramdisk"], p["second"], p["dt"]):
        if blob:
            out += pad(blob, page)
    return out


def has_mtk(blob):
    return blob[:4] == MTK_MAGIC


def main():
    if len(sys.argv) < 4:
        sys.exit(__doc__)
    kind, src, dst = sys.argv[1:4]
    hdr_file = sys.argv[4] if len(sys.argv) > 4 else os.path.join(
        os.path.dirname(os.path.abspath(__file__)), "zte_%s_header.bin" % kind)
    img = open(src, "rb").read()
    zte_hdr = open(hdr_file, "rb").read()
    assert len(zte_hdr) == ZTE_HDR_LEN, "unexpected ZTE header size"

    if img[:4] == zte_hdr[:4]:
        print("already wrapped, copying as-is")
        open(dst, "wb").write(img)
        return

    p = parse(img)
    if not has_mtk(p["kernel"]):
        p["kernel"] = mtk_hdr(len(p["kernel"]), b"KERNEL") + p["kernel"]
    if not has_mtk(p["ramdisk"]):
        rname = b"ROOTFS" if kind == "boot" else b"RECOVERY"
        p["ramdisk"] = mtk_hdr(len(p["ramdisk"]), rname) + p["ramdisk"]
    payload = build(p)
    zte_hdr = bytearray(zte_hdr)
    struct.pack_into("<I", zte_hdr, 0x44, len(payload))
    out = bytes(zte_hdr) + payload
    open(dst, "wb").write(out)
    print("wrapped %s: %d -> %d bytes" % (kind, len(img), len(out)))


if __name__ == "__main__":
    main()
