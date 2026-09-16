# iPad1Downloader v1.4 source

Unified lightweight network-transfer application for iPad 1 / iOS 5.1.1 / armv7 / MRC / Theos.

This repository is the active implementation base for the migration from `iPad1FTPDownloader` to `iPad1Downloader`.

## Current source state

Source implemented, **physical iPad 1 test pending**:

- existing FTP browse/download/upload and remote FTP operations retained;
- HTTP/HTTPS download screen added;
- HTTP response validation and redirect-friendly `NSURLConnection` flow;
- `suggestedFilename` / URL filename fallback;
- unique-name collision handling;
- `.part` temporary files;
- direct stream-to-disk;
- HTTP progress and speed;
- HTTP cancel;
- Windows -> iPad local Wi-Fi receive server;
- browser-based Windows upload page;
- one incoming Wi-Fi transfer at a time;
- six-digit session token for Wi-Fi receive;
- Wi-Fi receive writes directly to `.part` and finalizes on success;
- unified three-tab shell: `FTP`, `HTTP`, `Wi-Fi Al`.

Previously physically verified FTP behavior remains historical truth, but the **unified v1.4 package itself is not yet physically verified**.

## Transport ownership

`iPad1Downloader` owns network transfer only:

- FTP browse/download/upload and remote FTP operations;
- HTTP/HTTPS downloads;
- Windows -> iPad Wi-Fi receive over the local network;
- transfer progress/speed;
- retry/cancel/resume where the protocol supports it;
- bounded queue metadata;
- stream-to-disk behavior.

FTP, HTTP/HTTPS and Wi-Fi Receive remain separate transport engines. Protocol code is not mixed into one monolithic engine.

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

Until the external folder-picker contract is physically verified, HTTP and Wi-Fi Receive write only to this canonical root. Do not add another local browser to Downloader.

## Wi-Fi Receive

Low-memory flow:

```text
Windows browser
    -> same local Wi-Fi/LAN
    -> iPad1Downloader lightweight HTTP receive server :8080
    -> raw PUT body streamed to disk
    -> <filename>.part
    -> successful finalize
    -> /var/mobile/Media/iPad1Files/Downloads/<filename>
```

The iPad shows a local address similar to:

```text
http://192.168.x.x:8080/?token=123456
```

Open that address on Windows, choose a file and press `Gönder`.

The receiver does not parse multipart form uploads and does not load the complete file into RAM. The tiny HTML page sends the selected file as a raw HTTP `PUT`, which keeps the iPad-side implementation small.

## Completed-file hand-off

The same physical completed file is handed off by path only:

```text
PDF   -> ipad1pdf://open?path=...
video -> ipad1player://open?path=...
other -> ipad1files://show?path=...
```

No file is copied solely for integration.

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

## Build

```bash
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

Expected package identity after the v1.4 rename:

```text
com.olap.ipad1downloader
```

Physical iPad behavior remains authoritative. Do not mark HTTP or Wi-Fi Receive as verified until the built v1.4 package passes on-device testing.
