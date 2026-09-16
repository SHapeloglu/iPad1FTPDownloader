# iPad1Downloader Integration Contract

## Purpose

The former `iPad1FTPDownloader` is being evolved into **iPad1Downloader**, the network-transfer specialist of the iPad 1 application family.

It may own multiple network transports, but it must not absorb sibling-app responsibilities.

## Platform contract

- iPad 1
- Apple A4
- ~256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- non-ARC / MRC
- Theos
- legacy iPhoneOS 6.1 SDK

## Responsibility matrix

```text
FTP transfer / remote FTP operations -> iPad1Downloader / FTP engine
HTTP/HTTPS download                  -> iPad1Downloader / HTTP engine
Windows -> iPad Wi-Fi receive        -> iPad1Downloader / Wi-Fi receive engine
local filesystem / picker / ZIP      -> iPad1Files
PDF rendering/reading                -> iPad1PDFReader
video/audio playback/subtitles       -> iPad1Player
terminal/shell                       -> iPad1Terminal
VNC                                  -> iPad1VNC
```

Protocol ownership does not change based on file type. A video transferred over FTP is still an FTP transfer. A PDF received over Wi-Fi is still a Wi-Fi receive transfer. File type matters only after the transfer completes.

## Transport architecture

Keep protocol engines separate:

```text
iPad1Downloader
├── FTP engine
├── HTTP/HTTPS engine
├── Wi-Fi Receive engine
└── shared lightweight transfer state
    ├── progress
    ├── speed / ETA
    ├── bounded queue metadata
    ├── retry / cancel
    └── completed-file handoff
```

Do not merge FTP protocol code, HTTP protocol code and incoming-LAN server code into one monolithic class.

## Canonical shared storage

Owned by iPad1Files:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

One transferred file = one physical file.

Downloader must not create a duplicate private copy merely for integration.

## iPad1Files delegation

The following must be performed by `iPad1Files`, not implemented inside `iPad1Downloader`:

- local file/folder browser;
- destination folder selection UI;
- copy/move/rename/delete;
- ZIP/archive management;
- local search;
- favorites/tags/classification;
- downloaded-file organization;
- general file-management UI.

### Folder picker contract

When Downloader needs the user to choose a destination folder:

```text
ipad1files://pickFolder?root=<percent-encoded-root>&callback=<percent-encoded-callback>
```

For the unified downloader, recommended callback:

```text
ipad1downloader://folderSelected?path=<percent-encoded-absolute-path>
```

Until that receiving contract is physically verified, Downloader may use only the canonical `Downloads` root. It must not add its own fallback folder browser.

### Show downloaded file

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

Same physical file; no copy.

## Completed-file routing

Only after a transfer has completed successfully and the local file exists:

### PDF

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

### Video

Initial case-insensitive extensions:

```text
.mkv
.mp4
.mov
.m4v
.avi
```

Contract:

```text
ipad1player://open?path=<percent-encoded-absolute-path>
```

### Other files

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

Downloader must not render PDFs, decode video, discover subtitles, or implement a general local preview system.

## HTTP/HTTPS engine

Owns:

- HTTP/HTTPS URL download;
- redirects;
- response/status validation;
- `Content-Length`;
- `Content-Disposition` filename handling;
- `.part` temporary file;
- direct stream-to-disk;
- progress/speed/ETA;
- cancel/retry;
- HTTP Range resume with correct `206 Partial Content` validation;
- network-loss recovery where safe;
- bounded queue metadata.

## FTP engine

Owns:

- FTP connection/authentication;
- remote browse;
- FTP download/upload;
- remote rename/delete;
- MKD/RMD;
- saved FTP servers;
- remote search/sort;
- FTP-specific retry/resume semantics.

## Wi-Fi Receive engine

Purpose: transfer a file from a Windows machine to the iPad over the same local Wi-Fi/LAN.

Initial design:

```text
Windows browser
    -> local HTTP connection
    -> lightweight receive server on iPad1Downloader
    -> streamed file write
    -> canonical Downloads path
```

Requirements:

- no whole-file RAM buffering;
- one active incoming transfer initially;
- sanitize received filename;
- `.part` while receiving, final rename only on success;
- write only under the allowed shared root or a path returned by iPad1Files picker;
- no directory browser or file manager in the receiver;
- stop server when user disables Wi-Fi Receive or app exits;
- display local address/port and simple connection state;
- after completion, use the same sibling-app handoff rules.

A simple upload page is allowed only as the transport entry point. It must not become a local filesystem manager.

## Memory and concurrency policy

Safe defaults for iPad 1:

- one active large transfer at a time;
- small streaming buffers;
- bounded metadata-only queue;
- no whole-file `NSData` buffers;
- no segmented/multi-thread download initially;
- no large caches or thumbnails;
- no embedded browser/PDF/video subsystem.

## Physical-test rule

Source inspection and successful build are not feature verification.

Physical iPad 1 behavior is authoritative. A feature should be marked verified only after device testing.
