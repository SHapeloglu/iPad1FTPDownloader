# iPad1FTPDownloader

A lightweight legacy FTP/network-transfer client for **iPad 1 / iOS 5.1.1 / ARMv7**, built with Objective-C, UIKit, CFNetwork/CFFTP and Theos.

## Product role

iPad1FTPDownloader is the **network-transfer specialist** in the iPad 1 application family. It must not become a general filesystem manager or a PDF reader.

Target flow:

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

See `INTEGRATION.md` for the canonical application-family contract.

## Current status

### Confirmed on-device: v1.2

The following functionality has been exercised on an iPad 1 running iOS 5.1.1:

- FTP connection with host, port, username and password
- Remote directory listing
- Directory navigation
- Download
- Upload
- Transfer progress and speed display
- Saved-server support
- Remote rename/delete/new-folder infrastructure

v1.2 used the legacy local directory `/var/mobile/Media/iPad1FTPDownloads/`. That location is now deprecated for new development.

### In development: v1.3

v1.3 must be aligned with these decisions before it is considered complete:

- Canonical download root: `/var/mobile/Media/iPad1Files/Downloads/`
- No second copy of a completed download
- Remote directory path invariant: starts with `/` and ends with `/`
- FTP-owned search/sort, queue and pause/resume remain here
- Local Downloads view stays lightweight and transfer-oriented
- General filesystem management moves to iPad1Files
- PDF rendering moves to iPad1PDFReader via URL hand-off

**v1.3 is development code until it builds successfully and passes physical iPad 1 tests.**

## Target platform

- Device: iPad 1
- RAM: 256 MB
- Architecture: armv7
- OS: iOS 5.1.1
- Packaging: `.deb`
- Build system: Theos
- Language: Objective-C
- Memory management: Manual Reference Counting (`-fno-objc-arc`)
- UI: UIKit
- FTP transport: CFNetwork / CFFTPStream
- Transfer model: streaming

## Canonical local download directory

```text
/var/mobile/Media/iPad1Files/Downloads/
```

The application must create this directory when needed.

Do not create a second copy under the old path.

## PDF hand-off

For a completed `.pdf` download, the app may offer **PDFReader ile Aç** using:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

The same physical file must be opened. Do not copy it.

## iPad1Files hand-off

Optional integration:

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

This is a hand-off, not a reason to duplicate iPad1Files features in this app.

## FTP-owned feature scope

Keep these features in iPad1FTPDownloader:

- FTP connection
- remote folder browse
- download / upload
- pause / resume
- progress / speed
- FIFO queue
- remote rename / delete
- MKD / RMD
- saved servers
- remote search
- sorting

## Features intentionally delegated

General local file management belongs to iPad1Files:

- advanced copy/move
- broad folder management
- favorites
- filesystem-wide search
- file classification
- rich preview system
- Open With registry

PDF reading/rendering belongs to iPad1PDFReader.

## Remote path invariant

Every remote directory path must:

```text
start with /
end with /
```

Correct:

```text
/domains/example.com/public_html/css/
```

This rule applies to manual entry, current state, child navigation, parent navigation, refresh and FTP URL construction.

## Memory policy

Safe:

- streamed transfer
- small buffers
- FIFO queue metadata
- path/URL hand-off

Use caution:

- very long queues
- recursive remote search
- large local previews

Do not add:

- whole-file RAM buffering
- OCR
- AI/ML
- large background caches
- heavy SMB/SFTP libraries without profiling on the physical iPad 1

## SFTP and FTPS

Plain FTP is the currently implemented transport.

- SFTP requires a real SSH/SFTP library such as libssh2 compiled for armv7/iOS 5.
- FTPS requires a TLS-aware FTP control/data implementation.

Do not claim SFTP or FTPS support until the implementation is linked, built, profiled and verified on the physical iPad.

## Build

```bash
cd ~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

## Documentation

- `INTEGRATION.md` — application-family integration contract
- `ARCHITECTURE.md` — architecture and ownership boundaries
- `TASK.md` — current priorities
- `SESSION.md` — next-session hand-off
- `CLAUDE.md` — coding-agent project rules
- `AGENTS.md` — general coding-agent rules
- `TESTING.md` — build/device test plan
- `ROADMAP.md` — version roadmap
- `CHANGELOG.md` — release history
- `DEVELOPMENT.md` — build/deploy workflow

## Project principle

Reliability and clear responsibility boundaries matter more than feature count. iPad1FTPDownloader should do network transfer extremely well and hand the resulting file to the appropriate sibling application without duplication.
