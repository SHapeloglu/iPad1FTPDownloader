# v1.3 integration scope

- Canonical downloads: `/var/mobile/Media/iPad1Files/Downloads/`
- No duplicate app-owned copy after download
- Remote directory invariant: leading `/`, trailing `/`
- Child / parent / refresh / manual path normalization
- Existing FTP browse/download/upload/rename/delete/MKD/RMD retained
- PDF completion hand-off: `ipad1pdf://open?path=...`
- Optional file-manager hand-off: `ipad1files://show?path=...`
- Lightweight local download list only; rich preview/file-manager features removed from FTP scope
- iPad 1 / iOS 5.1.1 / armv7 / MRC / Theos / CFNetwork remains mandatory
