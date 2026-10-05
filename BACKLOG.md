# BACKLOG.md — iPad1FTPDownloader / iPad1Downloader

Scheduled work lives in `ROADMAP.md` (v1.3 → v1.7) and `TASK.md` (P0–P3). This file holds unscheduled items and research tracks. Every item must pass the ownership gate in `INTEGRATION.md` before it moves to `TASK.md`.

## Research tracks (not release dependencies)

- **SFTP / FTPS** — standalone armv7 / iOS 5 proof of concept first; profile RAM/CPU on the physical iPad 1 before any integration.
- **Direct media streaming** — only after the suite responsibility filter; must keep a clean transport-vs-playback boundary (no decoding here).

## Unscheduled ideas

- Bandwidth limit per transfer (useful when VNC/SSH share the same Wi-Fi).
- Transfer completion sound / local notification when the app is backgrounded (iOS 5 local notifications).
- Export/import of saved server list (without passwords) for moving between devices.
- Lightweight transfer log export for bug reports (metadata only, bounded).

## Open documentation inconsistency

`README.md` and `INTEGRATION.md` describe the app as the unified **iPad1Downloader** (FTP + HTTP/HTTPS + Wi-Fi receive engines, package 1.4.2), while `ROADMAP.md` still says HTTP/HTTPS must not enter this repository. Decide which document is authoritative and align the other before adding HTTP features.

## Explicitly out of scope

Local file management/pickers/ZIP (iPad1Files), PDF rendering (iPad1PDFReader), video playback (iPad1Player), terminal/SSH console (iPad1Terminal), VNC (iPad1VNC), general cloud/SMB file manager.
