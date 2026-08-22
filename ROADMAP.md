# ROADMAP.md

## Product direction

iPad1FTPDownloader is the focused **network-transfer specialist** for iPad 1 / iOS 5.1.1. General local file management belongs to iPad1Files; PDF reading belongs to iPad1PDFReader.

Canonical flow:

```text
FTP Server
   ↓
iPad1FTPDownloader
   ↓
/var/mobile/Media/iPad1Files/Downloads/
   ↓
iPad1Files
   ↓
iPad1PDFReader
```

## v1.3 — integration and stabilization

- Canonical download root: `/var/mobile/Media/iPad1Files/Downloads/`.
- Create shared Downloads automatically.
- One transfer = one physical file.
- Central remote-directory normalization: leading `/`, trailing `/`, root exactly `/`.
- Fix manual path, child navigation, parent navigation, refresh and URL creation with the same invariant.
- Preserve download/upload/rename/delete/MKD/RMD behavior.
- Same-path PDF hand-off through `ipad1pdf://open?path=...`.
- `Dosyalarda Göster` through `ipad1files://show?path=...`.
- Lightweight local transfer-results view only.
- Add download destination preference model:
  - `Son kullanılan klasör`
  - `Her indirmede sor`
  - `Her zaman Downloads'a indir`
- Add iPad1Files folder-picker hand-off using `ipad1files://pickFolder?...` and callback `ipad1ftp://folderSelected?...`.
- Validate selected folder remains under the canonical Downloads root.
- Add PDF post-download preference:
  - `Her seferinde sor`
  - `Otomatik PDFReader ile aç`
  - `Sadece indir`

Release only after physical-device verification.

## v1.4 — transfer manager

- Pause/resume/cancel.
- FTP REST/offset resume where supported.
- FIFO queue and bounded metadata.
- Retry failed transfer.
- Progress/speed/ETA.
- Overwrite / Resume / Rename collision handling.
- Small metadata-only transfer history.
- Connection-loss recovery.

All transfer implementations stay stream-based.

## v1.5 — FTP remote UX

- Improved Saved Servers editor.
- Remote filename/folder search.
- A→Z / Z→A sorting.
- Optional folder-first sorting.
- Human-readable remote metadata.
- Rename/delete/MKD/RMD polish.
- Upload target selection.
- Recursive search only if bounded/cancellable.

## v1.6 — sibling-app integration polish

- Robust iPad1Files folder-picker callback round-trip.
- Robust `Dosyalarda Göster`.
- Robust PDFReader hand-off.
- Same-file verification.
- Optional upload file-picker hand-in from iPad1Files.

## v1.7 — credential hardening

- iOS-5-compatible Keychain.
- Option not to save password.
- Anonymous FTP polish.
- Safe stored-credential update/delete.

## Experimental — SFTP / FTPS

SFTP and FTPS are research tracks, not release dependencies. Build a standalone armv7/iOS 5 proof-of-concept and profile RAM/CPU on physical iPad 1 before integrating any heavy library.

## Explicit non-goals

Do not add general local copy/move, broad folder management, favorites, filesystem-wide local search, classification, rich preview framework, full PDF reader, ZIP manager, text editor, Open With registry, SMB expansion, OCR, AI/ML, large background caches or whole-file RAM buffering.

## Product rule

- Network transfer → iPad1FTPDownloader
- Local filesystem/picker → iPad1Files
- PDF reading/rendering → iPad1PDFReader
