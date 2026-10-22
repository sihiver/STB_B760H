# LineageOS 14.1 for ZTE ZXV10 B760H (STB)

Porting and OS Upgrade dari Lenovo Tab 3 7 Essential (TB3-710F) ke ZTE ZXV10 B760H.

## Spesifikasi B760H
| Item | Spesifikasi |
| :--- | :--- |
| **SoC** | MediaTek MT8685 / MT8127 (Quad-Core Cortex-A7 @ 1.3GHz) |
| **GPU** | ARM Mali-450 MP4 |
| **RAM** | 1GB DDR3 |
| **Storage** | 4GB / 8GB eMMC |
| **Display Out** | HDMI (1080p / 720p) & CVBS RCA |
| **Stock OS** | Android 4.4.2 KitKat (ALPS.KK1.MP15) |
| **Target OS** | LineageOS 14.1 (Android 7.1.2 Nougat) |
| **Kernel** | Linux 3.10.108 (`b760h_defconfig`) |

## Penyesuaian Kunci dari Tablet ke STB
1. **Layar / Output Grafis:** Resolusi diatur ke 1080p (1920x1080) landscape 0° rotation via HDMI internal (`ro.sf.hwrotation=0`, `ro.sf.lcd_density=240`).
2. **Konektivitas:** Driver Ethernet RMII (RJ45 PHY) & USB Ethernet diaktifkan di kernel dan Android HAL.
3. **Input:** Keylayout `mtk-kpd.kl` bawaan ZTE B760H diintegrasikan agar Remote Control Infrared berfungsi (D-Pad, Menu, Back, Home, Volume).
4. **Partisi eMMC:** Mount point fstab disesuaikan dengan skema B760H (`p5` = `/system`, `p7` = `/cache`, `p6` = `/data`).
5. **Boot Image Header:** `mkbootimg.mk` membubuhkan header MTK (`88 16 88 58`) pada `zImage` dan `ramdisk` agar dikenali bootloader LK B760H.
