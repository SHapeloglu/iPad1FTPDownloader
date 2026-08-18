# CLAUDE.md

## Project identity

This repository is **iPad1FTPDownloader**, the network-transfer specialist for **iPad 1 / iOS 5.1.1 / armv7**.

The goal is not to become a general file manager. The goal is to provide reliable FTP/network transfer on a 256 MB legacy device and hand completed files to sibling applications through a shared physical path.

## Non-negotiable constraints

- iPad 1
- 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- UIKit APIs available to iOS 5
- Manual memory management / MRC
- Theos `.deb` packaging
- CFNetwork/CFFTP for current FTP transport
- stream-based transfer
- physical-device testing is authoritative

Do not introduce Swift, ARC assumptions, modern-only APIs, or large third-party frameworks casually.

## Authoritative integration contract

Read `INTEGRATION.md` before making architectural changes.

Canonical application-family flow:

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

## Canonical download root

All new FTP downloads must be written directly to:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Create the directory if it does not exist.

Do not use `/var/mobile/Media/iPad1FTPDownloads/` for new downloads.

Do not create a second copy solely to make the file visible to iPad1Files.

## Single physical file rule

One transferred file = one physical file.

Correct:

```text
/var/mobile/Media/iPad1Files/Downloads/example.pdf
```

Incorrect:

```text
/var/mobile/Media/iPad1FTPDownloads/example.pdf
/var/mobile/Media/iPad1Files/Downloads/example.pdf
```

## Responsibility boundary

### Keep here

- FTP connection
- remote folder browsing
- download/upload
- pause/resume
- transfer progress/speed
- FIFO queue
- remote rename/delete
- MKD/RMD
- saved servers
- remote search
- sorting

### Leave to iPad1Files

- advanced local copy/move
- broad local folder management
- favorites
- filesystem-wide search
- file classification
- rich/general preview system
- Open With registry

### Leave to iPad1PDFReader

- PDF rendering
- PDF reading features
- page navigation/zoom/bookmarks/etc.

## PDF hand-off

On completed `.pdf` transfer, use the same canonical file path:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Do not copy the PDF.

Optional iPad1Files hand-off:

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

## Remote directory path invariant

Every remote directory path must:

- start with `/`;
- end with `/`.

Examples:

```text
/
/domains/
/domains/example.com/
/domains/example.com/public_html/
```

Never let slashless directory state propagate internally.

Normalization must apply to:

- manual path entry;
- current path state;
- child navigation;
- parent navigation;
- refresh;
- URL construction.

## Memory policy

### Safe

- streamed reads/writes;
- 8–16 KB class buffers;
- small queue metadata;
- URL/path hand-offs.

### Caution

- recursive remote search;
- very long queues;
- large previews.

### Do not add

- whole-file RAM buffering;
- OCR;
- AI/ML;
- large background caches;
- SMB feature expansion;
- heavy SFTP libraries without profiling on the physical iPad 1.

## SFTP / FTPS rule

Do not claim SFTP or FTPS merely because UI, enums, stubs or integration points exist.

- SFTP requires a real SSH/SFTP library such as libssh2 compiled for armv7/iOS 5.
- FTPS requires a real TLS-capable FTP control/data implementation.

Before integrating libssh2:

1. build a minimal proof-of-concept;
2. confirm armv7/iOS 5 linkage;
3. measure memory footprint on the physical iPad;
4. only then integrate into the main app.

## Coding style

Prefer:

- small Objective-C classes;
- explicit delegates;
- UIKit/Foundation APIs available to iOS 5;
- defensive error handling;
- explicit MRC ownership;
- streamed network/file I/O;
- canonical-path helper functions used everywhere.

Avoid:

- duplicated path logic in multiple controllers;
- rich local file-manager subsystems;
- loading complete binary files for preview;
- blocking network I/O on the main thread;
- silent FTP server errors.

## Build environment

Typical location:

```text
~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
```

Build:

```bash
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

The `touch` step helps avoid WSL/archive clock-skew warnings.

## Deployment

Old iOS OpenSSH may require a per-command RSA compatibility flag:

```bash
scp -o HostKeyAlgorithms=+ssh-rsa <package.deb> root@<IP>:/var/mobile/
ssh -o HostKeyAlgorithms=+ssh-rsa root@<IP>
```

Do not weaken the host SSH configuration globally when a command-local compatibility flag is sufficient.

## Before making a release

1. Read `INTEGRATION.md`.
2. Build from a clean tree.
3. Verify package version in `control` and `Info.plist`.
4. Install on physical iPad 1.
5. Verify canonical shared Downloads root is used.
6. Verify no duplicate copy exists.
7. Verify child/parent directory navigation preserves leading/trailing slash invariant.
8. Verify download/upload.
9. Verify progress/speed.
10. Verify pause/resume if changed.
11. Verify queue if changed.
12. Verify remote rename/delete/MKD/RMD if changed.
13. Verify PDF hand-off opens the same physical file.
14. Verify local UI has not expanded into iPad1Files scope.
15. Update `CHANGELOG.md`, `SESSION.md`, `TASK.md`, and `TESTING.md` with actual results.
