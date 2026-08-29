# ROADMAP.md

## Product direction

iPad1FTPDownloader is the focused **network-transfer specialist** for iPad 1 / iOS 5.1.1. General local file management belongs to iPad1Files; PDF reading belongs to iPad1PDFReader; shell/terminal belongs to iPad1Terminal; VNC/remote desktop belongs to iPad1VNC.

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

Every competitor-derived feature must pass the ownership gate before entering this roadmap. A feature being present in FTPManager Pro, Documents or FE File Explorer is not by itself a reason to duplicate it here.

## v1.3 — integration and stabilization

- Canonical download root: `/var/mobile/Media/iPad1Files/Downloads/`.
- Create shared Downloads automatically.
- One transfer = one physical file.
- Central remote-directory normalization: leading `/`, trailing `/`, root exactly `/`.
- Fix manual path, child navigation, parent navigation, refresh and URL creation with the same invariant.
- Preserve download/upload/rename/delete/MKD/RMD behavior.
- Same-path PDF hand-off through `ipad1pdf://open?path=...`.
- `Dosyalarda Göster` through `ipad1files://show?path=...`.
- No embedded local preview/file-manager controllers.
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

High-value competitor parity that belongs to the FTP/network-transfer specialist:

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

Low-RAM competitor parity that remains inside FTP scope:

- Improved Saved Servers editor.
- Remote filename/folder search over the current loaded listing first.
- User-selectable A→Z / Z→A sorting.
- Folders-first ordering.
  - Development source now defaults to folders-first + case-insensitive A→Z.
  - Physical iPad verification is still required.
- Human-readable remote file size.
- Remote date/time metadata only where server listing format permits reliable parsing.
- Rename/delete/MKD/RMD polish.
- Remote upload target selection.
- Recursive search only if bounded/cancellable.

## v1.6 — sibling-app integration polish

- Robust iPad1Files folder-picker callback round-trip.
- Robust `Dosyalarda Göster`.
- Robust PDFReader hand-off.
- Same-file verification.
- Replace the temporary local upload chooser with iPad1Files `pickFile` once that receiving contract is physically verified.
- Never duplicate iPad1Files browsing UI merely to select an upload source.

See `SIBLING_APP_INSTRUCTIONS.md`.

## v1.7 — credential hardening

- iOS-5-compatible Keychain.
- Option not to save password.
- Anonymous FTP polish.
- Safe stored-credential update/delete.

## Experimental — SFTP / FTPS

SFTP and FTPS are still network-transfer features, but they are research tracks rather than release dependencies. Build a standalone armv7/iOS 5 proof-of-concept and profile RAM/CPU on physical iPad 1 before integrating any heavy library.

## Explicit sibling-owned capabilities

Do not implement these in FTPDownloader even when competitors bundle them into one app:

- local copy/move/folder management -> iPad1Files;
- local file/folder picker -> iPad1Files;
- ZIP/archive management -> iPad1Files;
- general image/document preview -> iPad1Files or relevant reader;
- PDF rendering/annotation -> iPad1PDFReader;
- text editing/general text-reader ownership -> sibling file/reader app;
- terminal/shell/SSH console -> iPad1Terminal;
- VNC/remote desktop -> iPad1VNC;
- broad media player -> sibling media-capable app if ever needed;
- general cloud/SMB file manager -> separate specialist, not FTPDownloader.

## Product rule

- Network transfer -> iPad1FTPDownloader
- Local filesystem/picker -> iPad1Files
- PDF reading/rendering -> iPad1PDFReader
- Terminal/shell -> iPad1Terminal
- VNC/remote desktop -> iPad1VNC

Prefer shared physical paths and lightweight URL-scheme hand-offs over duplicated subsystems.
