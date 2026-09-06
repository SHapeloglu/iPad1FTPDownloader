# ROADMAP.md

## Product direction

iPad1FTPDownloader is the focused **FTP specialist** for iPad 1 / iOS 5.1.1.

Suite ownership:

- FTP transfer / remote FTP operations -> iPad1FTPDownloader
- HTTP/HTTPS downloading -> iPad1Downloader
- local filesystem/pickers -> iPad1Files
- video playback/codecs/subtitles -> iPad1Player
- PDF reading/rendering -> iPad1PDFReader
- terminal/shell -> iPad1Terminal
- VNC/remote desktop -> iPad1VNC

A media file downloaded via FTP remains an FTPDownloader transfer until completion; only the completed local path is handed to iPad1Player.

Canonical FTP flow:

```text
FTP Server
   ↓
iPad1FTPDownloader
   ↓
/var/mobile/Media/iPad1Files/Downloads/
   ↓
completed-file hand-off
   ├─ video -> iPad1Player
   ├─ PDF   -> iPad1PDFReader
   └─ other -> iPad1Files
```

Every competitor-derived feature must pass the ownership gate before entering this roadmap.

## v1.3 — integration and stabilization

- Canonical download root: `/var/mobile/Media/iPad1Files/Downloads/`.
- Create shared Downloads automatically.
- One FTP transfer = one physical file.
- Central remote-directory normalization.
- Preserve FTP download/upload/rename/delete/MKD/RMD behavior.
- Same-path PDF hand-off through `ipad1pdf://open?path=...`.
- Same-path video hand-off through `ipad1player://open?path=...` for `.mkv/.mp4/.mov/.m4v/.avi` after successful completion only.
- `Dosyalarda Göster` through `ipad1files://show?path=...`.
- No embedded preview/player/file-manager controllers.
- Download destination preference model owned by FTPDownloader; actual folder picker owned by iPad1Files.
- Release only after physical-device verification.

## v1.4 — FTP transfer manager

- Pause/resume/cancel.
- FTP REST/offset resume where supported.
- FIFO queue and bounded metadata.
- Prefer one active FTP transfer at a time initially on iPad 1.
- Retry failed FTP transfers.
- Progress/speed/ETA.
- Overwrite / Resume / Rename collision handling.
- Small metadata-only transfer history.
- Connection-loss recovery.
- Stream directly to disk; never whole-file buffer.

## v1.5 — FTP remote UX

- Improved Saved Servers editor.
- Remote filename/folder search over current loaded listing.
- A→Z / Z→A sorting.
- Folders-first ordering.
- Human-readable remote file size.
- Remote date/time metadata where reliable.
- Rename/delete/MKD/RMD polish.
- Remote FTP upload target selection.
- Recursive search only if bounded/cancellable.

## v1.6 — sibling-app integration polish

- Robust iPad1Files folder-picker callback round-trip.
- Robust `Dosyalarda Göster`.
- Robust iPad1Player same-file hand-off.
- Robust iPad1PDFReader same-file hand-off.
- Same-file verification.
- Replace temporary local upload chooser with iPad1Files `pickFile` once physically verified.

## v1.7 — credential hardening

- iOS-5-compatible Keychain.
- Option not to save password.
- Anonymous FTP polish.
- Safe stored-credential update/delete.

## Explicit iPad1Downloader roadmap delegation

The following must not enter this repository's roadmap:

- HTTP/HTTPS download engine;
- browser URL downloader;
- redirect/cookie/header management;
- HTTP/HTTPS resume;
- HTTP/HTTPS queue/retry/failure management.

Those belong to iPad1Downloader. It may reuse the same completed-file hand-off contracts to Player/PDFReader/Files.

## Experimental — SFTP / FTPS

SFTP and FTPS are FTP/network protocol research tracks, not release dependencies. Build standalone armv7/iOS 5 proofs of concept and profile RAM/CPU on physical iPad 1 before integration.

## Explicit sibling-owned capabilities

Do not implement these in FTPDownloader even when competitors bundle them:

- HTTP/HTTPS downloads -> iPad1Downloader;
- local copy/move/folder management/pickers/ZIP -> iPad1Files;
- PDF rendering/annotation -> iPad1PDFReader;
- video playback/codecs/subtitles -> iPad1Player;
- terminal/shell/SSH console -> iPad1Terminal;
- VNC/remote desktop -> iPad1VNC;
- general cloud/SMB file manager -> separate specialist.

## Streaming

Direct media streaming is not automatically approved for FTPDownloader or Player. It must first pass the suite responsibility filter and preserve a clean transport-vs-playback boundary.

## Product rule

- FTP -> iPad1FTPDownloader
- HTTP/HTTPS -> iPad1Downloader
- local filesystem -> iPad1Files
- video playback -> iPad1Player
- PDF -> iPad1PDFReader
- terminal -> iPad1Terminal
- VNC -> iPad1VNC

Prefer shared physical paths and lightweight URL-scheme hand-offs over duplicated subsystems.
