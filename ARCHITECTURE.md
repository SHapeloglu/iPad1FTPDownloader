# ARCHITECTURE.md

## Overview

iPad1FTPDownloader is the **network-transfer specialist** for the iPad 1 application family. It is designed for first-generation iPads running iOS 5.1.1 with 256 MB RAM.

It must remain focused on remote FTP operations and efficient streamed transfer. General local filesystem management belongs to iPad1Files. PDF rendering belongs to iPad1PDFReader.

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
- stream-based transfers

## Application-family flow

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

## Shared storage boundary

Canonical local download root:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

The directory must be created if missing.

The old path:

```text
/var/mobile/Media/iPad1FTPDownloads/
```

is deprecated for new downloads.

### Single physical file invariant

A completed transfer is stored once, directly at its canonical location.

Do not copy the same file into a second app-owned folder.

## Layers

### UI layer

Responsibilities:

- connection fields;
- current remote path;
- remote directory table;
- remote search/sort controls;
- transfer progress/speed;
- queue status;
- lightweight list of completed local downloads;
- hand-off actions;
- error/status feedback.

The UI must not grow into a general-purpose file manager.

### FTP browsing layer

`FTPBrowser`

Responsibilities:

- build FTP directory URLs;
- apply credentials;
- read listing streams;
- parse listing items;
- return files/folders through a delegate.

Critical invariant:

```text
remote directory path starts with / and ends with /
```

Normalization must happen before directory state is stored, not merely before URL creation.

The invariant applies to:

- manual path entry;
- current path state;
- child navigation;
- parent navigation;
- refresh;
- URL construction.

### Download layer

`FTPDownloader`

Responsibilities:

- open CFFTP read stream;
- stream directly to the canonical local path;
- report progress/speed;
- support pause/resume using transfer offsets where supported;
- close streams safely.

Local target root:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

No post-download copy to iPad1Files is permitted.

### Upload layer

`FTPUploader`

Responsibilities:

- read local file incrementally;
- write to FTP output stream;
- report sent bytes and speed;
- avoid whole-file buffering.

Uploads may originate from the shared Downloads path or a path explicitly handed in by iPad1Files.

### Remote command layer

`FTPCommandClient`

Responsibilities:

- remote file delete (`DELE`);
- empty-directory remove (`RMD`);
- directory create (`MKD`);
- rename (`RNFR` / `RNTO`).

These are remote/network operations and therefore remain part of iPad1FTPDownloader.

### Transfer queue

`TransferQueue`

Responsibilities:

- store transfer metadata only;
- FIFO semantics;
- advance after finish/failure;
- avoid retaining file contents in memory.

Very long queues require profiling because the device has only 256 MB RAM.

### Lightweight local downloads view

Allowed responsibilities:

- list downloaded files;
- show transfer result;
- invoke file hand-off/open actions.

Not owned here:

- advanced local copy/move;
- general folder management;
- favorites;
- filesystem-wide search;
- classification;
- rich preview framework;
- Open With registry.

Those belong to iPad1Files.

## PDF hand-off

When a completed file is `.pdf`, the app may offer:

```text
PDFReader ile Aç
```

using:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

The same physical file path must be handed off. Do not copy it.

## iPad1Files hand-off

Optional scheme:

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

Use this for **Dosyalarda Göster** when available.

## Saved servers

Saved profile fields may include:

- display name;
- host;
- port;
- username;
- password;
- initial path.

Credential storage should eventually use an iOS-5-compatible Keychain implementation.

## Secure protocol boundary

### FTP

Implemented using CFNetwork/CFFTPStream plus a small FTP command client.

### SFTP

Not provided by CFFTPStream. Requires a real SSH/SFTP library such as libssh2 compiled for armv7/iOS 5.

Do not integrate a heavy SFTP dependency without profiling on the physical iPad 1.

### FTPS

Requires a TLS-aware FTP control/data implementation. Do not equate plain CFFTPStream with complete FTPS support.

## Memory policy

### Safe

- streaming download/upload;
- 8–16 KB class transfer buffers;
- queue metadata;
- path/URL hand-off.

### Caution

- recursive remote search;
- very long transfer queues;
- previewing large files.

### Forbidden by architecture

- loading an entire transfer into RAM;
- OCR;
- AI/ML;
- large background caches;
- duplicate physical copies created solely for app integration;
- heavy SMB/SFTP libraries without measured profiling.

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

Legacy SSH may require per-command `HostKeyAlgorithms=+ssh-rsa`.

## Ownership decision rule

- Primarily network transfer → **iPad1FTPDownloader**
- Primarily general local file management → **iPad1Files**
- Primarily PDF reading/rendering → **iPad1PDFReader**

Integration should be through canonical shared paths and lightweight hand-offs, not duplicated subsystems.
