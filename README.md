# iPad1FTPDownloader v1.3

Integration/stabilization build for iPad 1 / iOS 5.1.1 / armv7 / MRC / Theos.

## v1.3 focus

- Canonical download root: `/var/mobile/Media/iPad1Files/Downloads/`
- Creates the canonical directory when missing
- One transferred file = one physical file
- Remote directory path invariant: leading `/`, trailing `/`
- Same normalization for manual entry, current path, child, parent, refresh and FTP listing URL
- Existing FTP browse/download/upload/rename/delete/MKD/RMD retained
- PDF completion hand-off: `ipad1pdf://open?path=<percent-encoded-absolute-path>`
- Optional iPad1Files hand-off: `ipad1files://show?path=<percent-encoded-absolute-path>`

Rich local preview, general file management, ZIP/text-editor functionality and PDF rendering are intentionally outside this app.

## Build

```bash
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```
