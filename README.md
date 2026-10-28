# ZipDrop

Tien ich nho cho iOS: chon 1 file `.zip` (tu AirDrop/Files) va luu vao `Documents` cua chinh app,
xem danh sach va xoa nhanh.

- SwiftUI, iOS 15+, khong dung thu vien ngoai
- Khong mang, khong quyen dac biet
- Build bang GitHub Actions (macos-14) ra `.ipa`, cai bang TrollStore/AltStore

## Build

```bash
chmod +x build.sh && ./build.sh
```

Hoac push len GitHub, workflow `build-ipa` chay va tra artifact.

## Cai

Tai artifact `ZipDrop-ipa` -> giai nen -> cai `.ipa` bang TrollStore.
