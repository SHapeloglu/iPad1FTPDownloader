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

## Core layers

### UI layer

Responsibilities:

- connection fields;
- current remote path;
- remote directory table;
- remote search/sort controls;
- transfer progress/speed;
- transfer queue state;
- lightweight list of completed downloads;
- sibling-app hand-off actions;
- error/status feedback.

The UI must not grow into a general-purpose file manager.

### Canonical remote-path helper

One shared helper must normalize remote **directory** paths before they are stored or used.

Invariant:

```text
starts with /
ends with /
root is exactly /
```

The same helper must be used by:

- manual path entry;
- current-path assignment;
- child-directory navigation;
- parent navigation;
- refresh;
- FTP URL construction.

Do not duplicate path-fixing logic across controllers.

### FTP browsing layer

`FTPBrowser`

Responsibilities:

- build FTP directory URLs from already-normalized directory paths;
- apply credentials;
- read directory-listing streams;
- parse server listing into file/folder metadata;
- return items through a delegate.

Do not recursively cache the full server tree.

### Download layer

`FTPDownloader`

Responsibilities:

- open CFFTP read stream;
- stream directly to `/var/mobile/Media/iPad1Files/Downloads/`;
- create the canonical local directory if needed;
- report progress and speed;
- support pause/resume using FTP transfer offsets where server/CFNetwork support permits it;
- close streams safely on finish/failure/pause/cancel.

No post-download copy to iPad1Files is permitted.

### Upload layer

`FTPUploader`

Responsibilities:

- read local files incrementally;
- write to FTP output stream;
- report sent bytes and speed;
- avoid whole-file buffering.

Uploads may originate from the canonical shared Downloads root or from a local path explicitly handed in by iPad1Files.

### Remote command layer

`FTPCommandClient`

Responsibilities:

- `DELE` remote file delete;
- `RMD` empty-directory remove;
- `MKD` directory creation;
- `RNFR` / `RNTO` rename.

These operations stay in iPad1FTPDownloader because they are remote FTP operations.

### Transfer manager

`TransferQueue` and related transfer-state code own:

- metadata-only FIFO queue;
- current transfer state;
- pause/resume/cancel/retry;
- advancement to the next queued item;
- small transfer history if implemented.

The queue must never retain file contents.

### Lightweight local downloads view

Allowed responsibilities:

- list completed downloads;
- show basic transfer result information;
- request open/hand-off actions.

Not owned here:

- advanced local copy/move;
- general folder management;
- favorites;
- filesystem-wide search;
- classification;
- rich/general preview framework;
- ZIP management;
- text editing;
- Open With registry.

Those belong to iPad1Files or a sibling specialist application.

## PDF hand-off

When a completed file has a `.pdf` extension, the app may offer:

```text
PDFReader ile Aç
```

using:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

The same canonical physical file must be opened. Never copy it merely for hand-off.

## iPad1Files hand-off

Optional scheme:

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

Use this for **Dosyalarda Göster** when the sibling app supports it.

## Saved servers

Saved profile fields may include:

- display name;
- host;
- port;
- username;
- password;
- initial remote path.

Credential storage should eventually use an iOS-5-compatible Keychain implementation.

## FTP UX scope

The following remain first-class product responsibilities:

- FTP connection;
- remote browse;
- download/upload;
- pause/resume/cancel;
- queue/retry;
- progress/speed/ETA;
- saved servers;
- remote search;
- sorting;
- rename/delete/MKD/RMD.

## Secure protocol research boundary

### SFTP

Not provided by CFFTPStream. Requires a real SSH/SFTP library such as libssh2 compiled for armv7/iOS 5.

SFTP integration is experimental until a standalone proof-of-concept has been built and profiled on the physical iPad 1.

### FTPS

Requires a TLS-aware FTP control/data implementation. It must be researched separately from SFTP.

Do not claim FTPS merely because plain CFFTPStream works.

## Memory policy

### Safe

- streaming download/upload;
- small transfer buffers, approximately 8–16 KB class;
- queue metadata;
- path/URL hand-off.

### Caution

- recursive remote search;
- very long transfer queues;
- excessive history retention;
- heavy secure-protocol dependencies.

### Forbidden by architecture

- loading complete transferred files into RAM;
- duplicate physical files created solely for app integration;
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

Legacy SSH may require per-command `HostKeyAlgorithms=+ssh-rsa`.

## Ownership decision rule

- Primarily network transfer → **iPad1FTPDownloader**
- Primarily general local file management → **iPad1Files**
- Primarily PDF reading/rendering → **iPad1PDFReader**

Integration must use canonical shared paths and lightweight hand-offs, not duplicated subsystems or duplicated files.
