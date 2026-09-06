# CLAUDE.md

## Project identity

This repository is **iPad1FTPDownloader**, the FTP specialist for **iPad 1 / iOS 5.1.1 / armv7**.

The goal is reliable FTP transfer on a 256 MB legacy device. It must not become a generic HTTP/HTTPS downloader, local file manager, media player or PDF reader.

## Read first

Before architectural or scope changes, read in this order:

1. `INTEGRATION.md`
2. `ARCHITECTURE.md`
3. `TASK.md`
4. `SESSION.md`
5. `TESTING.md`

`INTEGRATION.md` is authoritative for cross-app ownership.

## Non-negotiable constraints

- iPad 1
- 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- UIKit APIs available to iOS 5
- Manual memory management / MRC
- Theos `.deb` packaging
- CFNetwork/CFFTP for FTP
- stream-based transfer
- physical-device testing is authoritative

## Responsibility boundary

### Keep in iPad1FTPDownloader

- FTP connection/authentication
- remote FTP browsing
- FTP download/upload
- FTP pause/resume/cancel/retry
- FTP progress/speed/ETA
- bounded FIFO transfer queue
- failed FTP transfer handling
- saved FTP servers
- remote search/sorting
- remote rename/delete
- MKD/RMD
- transfer-oriented local result state
- completed-file sibling-app path hand-off

### Leave to iPad1Downloader

- HTTP downloads
- HTTPS downloads
- browser/web URL download workflows
- redirect/cookie/header handling
- HTTP/HTTPS resume semantics
- HTTP/HTTPS queue/retry/failure management

### Leave to iPad1Files

- local filesystem browsing/pickers
- advanced copy/move
- folder management
- favorites
- filesystem-wide local search
- ZIP/archive
- rich/general preview
- text editing
- Open With registry

### Leave to iPad1Player

- video decode/playback
- codecs
- seek/playback controls
- subtitle discovery/rendering

### Leave to iPad1PDFReader

- PDF rendering
- page navigation
- zoom/bookmarks/highlights

### Other specialists

- terminal/shell -> iPad1Terminal
- VNC/remote desktop -> iPad1VNC

A media file does not change transfer ownership. FTP media is transferred here and only the successfully completed accessible local path is handed to Player.

## Canonical application-family flow

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

HTTP/HTTPS sources use iPad1Downloader instead.

## Canonical download root

All new FTP downloads must be written directly to:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Do not create new downloads in `/var/mobile/Media/iPad1FTPDownloads/` and do not copy completed files merely for sibling integration.

## Remote path invariant

Every remote FTP directory path must:

- start with `/`;
- end with `/`;
- represent root as exactly `/`.

Use one canonical helper everywhere: manual entry, current state, child navigation, parent navigation, refresh and listing URL construction.

## Completed-file hand-off

### Video

For completed `.mkv`, `.mp4`, `.mov`, `.m4v`, `.avi` files:

```text
ipad1player://open?path=<percent-encoded-absolute-path>
```

Do not decode/play media in FTPDownloader.

### PDF

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

### Files

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

All use the same physical file. If a sibling scheme is unavailable, leave the file untouched and fail gracefully.

## Current roadmap order

### v1.3

- canonical shared Downloads root
- single physical file rule
- centralized remote path invariant
- Player/PDFReader/Files same-path hand-off
- FTP regression testing
- download destination preference + iPad1Files picker integration

### v1.4

- FTP pause/resume/cancel
- bounded queue
- retry/failure recovery
- progress/speed/ETA
- collision handling
- metadata-only history
- deliberately low concurrency on iPad 1

### v1.5

- Saved Servers editor
- remote search/sort
- folders-first
- remote metadata
- remote operations polish

### v1.6

Sibling-app integration polish.

### v1.7

Keychain-backed saved credentials and related hardening.

### HTTP/HTTPS

Explicitly outside this repository; belongs to iPad1Downloader.

### SFTP/FTPS

Experimental research only until physical-device profiling proves acceptable.

## Memory policy

### Safe

- streamed FTP reads/writes
- small buffers around 8–16 KB class
- bounded queue/history metadata
- URL/path hand-offs

### Caution

- recursive remote search
- simultaneous transfers
- very long queues
- heavy secure-protocol libraries

### Do not add

- whole-file RAM buffering
- HTTP/HTTPS downloader subsystem
- media playback/codec/subtitle engine
- rich local preview framework
- PDF rendering
- OCR
- AI/ML
- large background caches
- SMB expansion
- heavy SFTP dependencies without profiling

## SFTP / FTPS rule

Never claim SFTP or FTPS support because a stub or UI element exists. Require a real armv7/iOS 5 implementation and physical profiling.

## Coding style

Prefer small Objective-C classes, explicit delegates, iOS-5-compatible APIs, explicit MRC ownership, defensive error handling, streamed file/network I/O and one shared path-normalization helper.

Avoid duplicated path logic, hidden whole-file reads, blocking network operations on the main thread, swallowed FTP errors, HTTP downloader scope creep, local file-manager scope creep and media playback scope creep.

## Build

```bash
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

## Release checklist

1. Read `INTEGRATION.md`.
2. Build from a clean tree.
3. Install on physical iPad 1.
4. Verify canonical shared download root and no duplicate copy.
5. Verify remote path invariant.
6. Verify FTP download/upload and remote commands.
7. Verify transfer progress/speed and changed transfer-manager behavior.
8. Verify Player/PDFReader/Files hand-offs use the same completed physical file.
9. Verify local UI remains FTP-transfer-oriented.
10. Confirm no HTTP/HTTPS downloader or media playback logic was introduced.
11. Update `CHANGELOG.md`, `SESSION.md`, `TASK.md` and `TESTING.md` with actual physical results.
