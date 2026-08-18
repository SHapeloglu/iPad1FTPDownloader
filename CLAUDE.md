# CLAUDE.md

## Project identity

This repository is **iPad1FTPDownloader**, the network-transfer specialist for **iPad 1 / iOS 5.1.1 / armv7**.

The goal is reliable FTP/network transfer on a 256 MB legacy device. It must not become a general local file manager or a PDF reader.

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
- CFNetwork/CFFTP for the current FTP implementation
- stream-based transfer
- physical-device testing is authoritative

Do not introduce Swift, ARC assumptions, modern-only APIs or large dependencies casually.

## Canonical application-family flow

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

Do not create new downloads in:

```text
/var/mobile/Media/iPad1FTPDownloads/
```

Do not copy a completed file into another app-owned directory merely for integration.

## Responsibility boundary

### Keep in iPad1FTPDownloader

- FTP connection
- remote directory browsing
- download/upload
- pause/resume/cancel
- retry
- progress/speed/ETA
- FIFO queue
- saved servers
- remote search/sorting
- remote rename/delete
- MKD/RMD
- transfer-oriented local results list
- sibling-app path hand-off

### Leave to iPad1Files

- advanced local copy/move
- broad local folder management
- favorites
- filesystem-wide local search
- file classification
- rich/general preview system
- ZIP management
- text editing
- Open With registry

### Leave to iPad1PDFReader

- PDF rendering
- PDF page navigation
- zoom/bookmarks/highlights/reader features

## Remote path invariant

Every remote **directory** path must:

- start with `/`;
- end with `/`;
- represent root as exactly `/`.

Use one canonical helper everywhere. Do not scatter manual slash fixes through controllers.

Normalization must apply to:

- manual entry;
- current path state;
- child navigation;
- parent navigation;
- refresh;
- listing URL construction.

Example:

```text
/domains/example.com/public_html/css/
```

not:

```text
domains/example.com/public_html/css
/domains/example.com/public_html/css
```

## PDF hand-off

On completed `.pdf` transfer, offer the same canonical physical file through:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Do not copy the PDF.

Optional iPad1Files hand-off:

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

If the sibling scheme is unavailable, fail gracefully and leave the file untouched.

## Current roadmap order

Do not skip ahead unless explicitly requested.

### v1.3

Integration and stabilization:

- canonical shared Downloads root;
- single physical file rule;
- centralized remote path invariant;
- PDF/iPad1Files hand-off;
- FTP regression testing;
- lightweight local results screen.

### v1.4

Transfer manager:

- pause/resume/cancel;
- queue;
- retry;
- progress/speed/ETA;
- collision handling;
- bounded metadata-only history.

### v1.5

FTP remote UX:

- Saved Servers editor;
- remote search/sort;
- folder-first option;
- remote metadata;
- remote operations polish.

### v1.6

Sibling-app integration polish.

### v1.7

Keychain-backed saved credentials and related hardening.

### SFTP/FTPS

Experimental research only until physical-device profiling proves acceptable.

## Memory policy

### Safe

- streamed reads/writes;
- small buffers around 8–16 KB class;
- small queue/history metadata;
- URL/path hand-offs.

### Caution

- recursive remote search;
- very long queues;
- heavy secure-protocol libraries.

### Do not add

- whole-file RAM buffering;
- rich local preview framework;
- OCR;
- AI/ML;
- large background caches;
- SMB expansion;
- heavy SFTP dependencies without profiling.

## SFTP / FTPS rule

Never claim SFTP or FTPS support because a stub, enum, UI control or integration point exists.

For SFTP:

1. build libssh2 for armv7/iOS 5 in a standalone proof-of-concept;
2. link successfully;
3. connect/list/download/upload;
4. profile idle RAM, transfer RAM and CPU on physical iPad 1;
5. integrate only if stable and lightweight enough.

FTPS must be researched independently with real TLS-aware FTP control/data channels.

## Coding style

Prefer:

- small Objective-C classes;
- explicit delegates;
- Foundation/UIKit APIs available to iOS 5;
- explicit MRC ownership;
- defensive error handling;
- streamed file/network I/O;
- one shared path-normalization helper.

Avoid:

- duplicated path logic;
- hidden whole-file reads;
- blocking network operations on the main thread;
- swallowed FTP server errors;
- local file-manager scope creep.

## Build

Typical location:

```text
~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
```

```bash
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

## Deployment

Legacy iOS OpenSSH may require:

```bash
scp -o HostKeyAlgorithms=+ssh-rsa <package.deb> root@<IP>:/var/mobile/
ssh -o HostKeyAlgorithms=+ssh-rsa root@<IP>
```

Use command-local legacy compatibility rather than weakening the development host globally.

## Release checklist

1. Read `INTEGRATION.md`.
2. Build from a clean tree.
3. Confirm package/version metadata.
4. Install on physical iPad 1.
5. Verify canonical shared download root.
6. Verify no duplicate physical copy.
7. Verify remote path invariant through child/parent/manual/refresh cases.
8. Verify download/upload and remote commands.
9. Verify transfer progress/speed and any changed transfer-manager behavior.
10. Verify PDF hand-off uses the same physical file.
11. Verify local UI remains transfer-oriented.
12. Update `CHANGELOG.md`, `SESSION.md`, `TASK.md` and `TESTING.md` with actual results.
