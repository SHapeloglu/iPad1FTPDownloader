# ARCHITECTURE.md

## Overview

iPad1FTPDownloader is the **FTP specialist** for the iPad 1 application family. It is designed for first-generation iPads running iOS 5.1.1 with 256 MB RAM.

It must remain focused on remote FTP operations and efficient streamed FTP transfer. Generic HTTP/HTTPS downloading belongs to iPad1Downloader. General local filesystem management belongs to iPad1Files. Media playback belongs to iPad1Player. PDF rendering belongs to iPad1PDFReader.

## Mandatory sibling-app ownership gate

Before proposing, designing or implementing **any** new feature, first determine which application owns the responsibility.

```text
New feature request
      ↓
Which specialist app owns this responsibility?
      ↓
FTP transfer / remote FTP operation → iPad1FTPDownloader
HTTP/HTTPS download                 → iPad1Downloader
Local filesystem / picker           → iPad1Files
Video playback / codecs / subtitles → iPad1Player
PDF rendering / reading             → iPad1PDFReader
Terminal / shell                     → iPad1Terminal
VNC / remote desktop                 → iPad1VNC
      ↓
If another app owns it: integrate/hand off; do not duplicate it here.
```

A file's type does not determine transfer ownership. Transport determines the downloader:

- video over FTP -> iPad1FTPDownloader performs the transfer, then hands the completed file to iPad1Player;
- video over HTTP/HTTPS -> iPad1Downloader performs the transfer, then hands the completed file to iPad1Player.

Never add a feature here solely because a competitor bundles FTP, HTTP downloading, file management and playback into one app.

## Platform constraints

- iPad 1
- 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- non-ARC / MRC
- Theos
- UIKit APIs available to iOS 5
- CFNetwork / CFFTP
- stream-based FTP transfers

## Application-family flow

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

HTTP/HTTPS sources follow a separate path through iPad1Downloader and are not implemented by this application.

## Shared storage boundary

Canonical local download root:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

The directory must be created if missing.

The old path `/var/mobile/Media/iPad1FTPDownloads/` is deprecated for new downloads.

### Single physical file invariant

A completed transfer is stored once, directly at its canonical location. Do not copy the same file into another app-owned folder merely for integration.

## Core layers

### UI layer

Responsibilities:

- FTP connection fields;
- current remote FTP path;
- remote directory table;
- remote search/sort controls;
- FTP transfer progress/speed;
- FTP transfer queue state;
- lightweight completed-transfer results;
- sibling-app hand-off actions;
- FTP error/status feedback.

The UI must not grow into a browser downloader, general-purpose file manager, media player or PDF reader.

### Canonical remote-path helper

Every remote FTP directory path must:

```text
start with /
end with /
root is exactly /
```

Use one canonical helper for manual entry, current-path assignment, child navigation, parent navigation, refresh and FTP URL construction.

### FTP browsing layer

`FTPBrowser` owns FTP directory listing only:

- build FTP directory URLs from normalized paths;
- apply credentials;
- read directory-listing streams;
- parse server listing into file/folder metadata;
- return items through a delegate.

Do not recursively cache the full server tree.

### FTP download layer

`FTPDownloader` owns FTP transfer mechanics:

- open CFFTP read stream;
- stream directly to disk;
- create the canonical local directory if needed;
- report progress and speed;
- support pause/resume through FTP offsets where server/CFNetwork support permits it;
- close streams safely on finish/failure/pause/cancel.

No post-download copy is permitted for sibling integration.

### Upload layer

`FTPUploader` owns FTP upload only:

- read local files incrementally;
- write to FTP output stream;
- report sent bytes and speed;
- avoid whole-file buffering.

The local source path may be handed in by iPad1Files.

### Remote command layer

`FTPCommandClient` owns remote FTP operations:

- `DELE`;
- `RMD`;
- `MKD`;
- `RNFR` / `RNTO`.

### Transfer manager

`TransferQueue` and related FTP transfer-state code own:

- metadata-only FIFO queue;
- current FTP transfer state;
- pause/resume/cancel/retry;
- failed-transfer recovery;
- bounded history if implemented.

The queue must never retain file contents. On iPad 1, prefer one active transfer at a time or similarly low bounded concurrency.

## Completed-file hand-off

Hand-off happens only after a transfer finishes successfully and the local file is accessible.

### Video

Case-insensitive extensions:

```text
.mkv .mp4 .mov .m4v .avi
```

Use:

```text
ipad1player://open?path=<percent-encoded-absolute-path>
```

FTPDownloader must not decode, render, seek, inspect subtitles or play video.

### PDF

Use:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

### Other files / show in files

Use:

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

All hand-offs use the same physical file.

## Explicit iPad1Downloader boundary

Do not implement these in iPad1FTPDownloader:

- generic HTTP/HTTPS download;
- browser/web URL download workflows;
- HTTP redirects;
- HTTP cookies/headers;
- HTTP/HTTPS resume semantics;
- HTTP/HTTPS queue/retry/failure management.

Those belong to iPad1Downloader.

## Local browser scope

Allowed here only for transfer-oriented results and sibling-app hand-off. General local copy/move, folder management, favorites, filesystem-wide search, ZIP/archive, rich preview, text editing and Open With belong to iPad1Files or another specialist app.

## Secure protocol research boundary

### SFTP

SFTP is not provided by CFFTPStream. Any implementation requires a real SSH/SFTP library compiled for armv7/iOS 5 and physical-device profiling before integration.

### FTPS

FTPS requires a real TLS-aware FTP implementation and must be evaluated separately.

## Streaming boundary

Future direct media streaming is not automatically assigned to FTPDownloader or Player. It must first pass the suite responsibility gate. Network transport state and media decode/render state must remain separable.

## Memory policy

### Safe

- streamed FTP read/write;
- small transfer buffers, approximately 8–16 KB class;
- bounded queue metadata;
- path/URL hand-offs.

### Caution

- simultaneous transfers;
- recursive remote search;
- very long queues;
- heavy secure-protocol dependencies.

### Forbidden by architecture

- loading complete transferred files into RAM;
- HTTP/HTTPS downloader subsystem;
- duplicate physical files for integration;
- media decode/playback;
- PDF rendering;
- general rich-preview subsystem;
- OCR;
- AI/ML;
- large background caches;
- SMB expansion;
- heavy SFTP libraries without measured physical-device profiling.

## Build/deployment topology

```text
Windows + WSL Ubuntu + Theos
        ↓
      .deb
        ↓
      SCP
        ↓
jailbroken iPad 1
        ↓
     dpkg -i
```

## Ownership decision rule

- FTP transfer / remote FTP operation -> **iPad1FTPDownloader**
- HTTP/HTTPS download -> **iPad1Downloader**
- Local filesystem / picker -> **iPad1Files**
- Video playback / codecs / subtitles -> **iPad1Player**
- PDF reading / rendering -> **iPad1PDFReader**
- Terminal / shell -> **iPad1Terminal**
- VNC / remote desktop -> **iPad1VNC**

This decision must be made before implementation. Prefer shared physical paths and lightweight URL-scheme hand-offs over duplicated subsystems or duplicated files.
