# iPad1Downloader

Unified lightweight network-transfer application for iPad 1 / iOS 5.1.1 / armv7 / MRC / Theos.

This repository is being migrated from the former `iPad1FTPDownloader` identity to the broader `iPad1Downloader` role.

## Transport ownership

`iPad1Downloader` owns network transfer only:

- FTP browse/download/upload and remote FTP operations;
- HTTP/HTTPS downloads;
- Windows -> iPad Wi-Fi receive over the local network;
- transfer progress/speed/ETA;
- retry/cancel/resume where the protocol supports it;
- bounded queue metadata;
- stream-to-disk behavior.

FTP, HTTP/HTTPS and Wi-Fi Receive remain separate transport engines. They may share transfer-state UI and lightweight queue/progress infrastructure, but protocol code must not be mixed into one monolithic engine.

## iPad1Files boundary

`iPad1Downloader` must **not** implement local file-manager responsibilities.

These belong to `iPad1Files`:

- local file/folder browsing;
- destination folder picker;
- copy/move/rename/delete;
- ZIP/archive handling;
- local search/favorites;
- downloaded-file organization;
- general `Open With` / file-management UI.

Canonical shared download root:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

When a destination picker is needed, use the `iPad1Files` hand-off contract instead of implementing another folder browser.

## Wi-Fi Receive

Windows -> iPad transfer is a network-transfer responsibility and therefore belongs to `iPad1Downloader`.

Initial low-memory design:

```text
Windows browser
    -> local Wi-Fi/LAN
    -> iPad1Downloader lightweight receive server
    -> streamed write
    -> /var/mobile/Media/iPad1Files/Downloads/
```

The receiver must not load the complete upload into RAM. The initial version should prefer one active incoming transfer.

After receipt, the same physical file is handed off by path only:

```text
PDF   -> ipad1pdf://open?path=...
video -> ipad1player://open?path=...
other -> ipad1files://show?path=...
```

No file is copied solely for integration.

## Other sibling boundaries

- PDF rendering/reading -> `iPad1PDFReader`
- video/audio playback and subtitles -> `iPad1Player`
- terminal/shell -> `iPad1Terminal`
- VNC -> `iPad1VNC`

## Platform rules

- iPad 1 / Apple A4 / ~256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C / non-ARC MRC
- legacy iPhoneOS 6.1 SDK
- direct stream-to-disk
- one active large transfer preferred
- no whole-file RAM buffering
- no embedded general file manager
- no embedded PDF/video engines

Physical iPad behavior remains authoritative.
