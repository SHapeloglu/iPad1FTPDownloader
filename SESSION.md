# SESSION.md

## Latest hand-off

Date: 2026-08-18

## Working context

The project is developed in WSL Ubuntu with Theos for a jailbroken iPad 1 running iOS 5.1.1.

Typical local project path:

```text
~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
```

Typical iPad development IP observed recently:

```text
192.168.1.2
```

The IP can change. Verify before deployment.

## Confirmed history

### v1.0

Initial FTP downloader built and installed successfully.

### v1.1

Added FTP directory browsing and tap-to-download. Physical-device testing confirmed directory listing and download.

### v1.2

Added upload, saved-server work, transfer progress/speed and remote file-operation infrastructure. Upload progress reached 100% on the physical iPad.

## Known remote-path bug

On iOS 5 CFNetwork, FTP directory listing may fail unless the remote directory path ends with `/`.

Required invariant:

```text
all remote directories start with / and end with /
root is exactly /
```

An earlier patch that only appended `/` to the final FTP URL was insufficient because application state could still contain slashless directory paths.

The correct fix is to centralize normalization and use it for:

- manual path entry;
- current path assignment;
- child navigation;
- parent navigation;
- refresh;
- FTP listing URL construction.

## Authoritative integration decision

iPad1FTPDownloader is the **network-transfer specialist** in the iPad 1 app family.

Canonical flow:

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

### Canonical download root

New downloads must go directly to:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Create the directory automatically when missing.

Do not create new downloads under:

```text
/var/mobile/Media/iPad1FTPDownloads/
```

### Single physical file rule

A transferred file has one physical copy. Do not copy it again into iPad1Files after completion.

### PDF hand-off

For completed `.pdf` files:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Use the same canonical file path.

Optional iPad1Files hand-off:

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

## Scope ownership

Keep in iPad1FTPDownloader:

- FTP connection;
- remote browse;
- download/upload;
- pause/resume/cancel/retry;
- progress/speed/ETA;
- FIFO queue;
- saved servers;
- remote search/sort;
- remote rename/delete;
- MKD/RMD;
- lightweight transfer-results list;
- sibling-app path hand-off.

Delegate to iPad1Files:

- advanced local copy/move;
- general folder management;
- favorites;
- filesystem-wide local search;
- classification;
- rich/general preview;
- ZIP management;
- text editing;
- Open With registry.

Delegate PDF rendering/reader functionality to iPad1PDFReader.

## Revised roadmap

### v1.3 — integration/stabilization

Immediate release target:

1. change download root to `/var/mobile/Media/iPad1Files/Downloads/`;
2. create the shared path automatically;
3. ensure no duplicate copy;
4. centralize remote-directory normalization;
5. verify child/parent/manual/refresh path behavior;
6. preserve download/upload/remote-command functionality;
7. add PDFReader hand-off;
8. optionally add iPad1Files show hand-off;
9. keep local UI lightweight;
10. build/install/test on physical iPad 1.

### v1.4 — transfer manager

- pause/resume/cancel;
- FIFO queue;
- retry;
- progress/speed/ETA;
- overwrite/resume/rename collision choice;
- small metadata-only history;
- connection-loss handling.

### v1.5 — FTP remote UX

- improved Saved Servers editor;
- remote search;
- sorting/folder-first option;
- remote metadata;
- remote operation polish.

### v1.6 — sibling-app integration polish

- robust PDFReader/iPad1Files hand-off;
- same-file verification;
- optional upload path hand-in from iPad1Files if defined.

### v1.7 — credential hardening

- iOS-5-compatible Keychain;
- optional no-save-password behavior;
- Anonymous FTP polish.

### SFTP / FTPS

Experimental research only. Do not make them release dependencies.

For SFTP, first build a standalone armv7/iOS 5 libssh2 proof-of-concept and measure RAM/CPU on the physical iPad. Integrate only if acceptable.

## Memory policy

Safe:

- streaming transfers;
- small buffers;
- small queue/history metadata;
- path hand-offs.

Use caution:

- recursive remote search;
- very long queues;
- heavy secure-protocol libraries.

Do not add:

- whole-file RAM buffering;
- rich local preview framework;
- OCR;
- AI/ML;
- large background caches;
- SMB expansion;
- heavy SFTP dependencies without profiling.

## Immediate next action

Modify the actual v1.3 source to match `INTEGRATION.md` and the revised roadmap.

Start with the highest-impact source changes:

1. replace all download-root constants/usages with `/var/mobile/Media/iPad1Files/Downloads/`;
2. ensure the directory is created;
3. centralize remote directory normalization;
4. remove/avoid rich local preview code that duplicates sibling-app responsibility;
5. add same-path PDF hand-off;
6. build and test.

Local start:

```bash
cd ~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
pwd
ls
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

## Deployment reminder

WSL prompt:

```text
yeliz@DESKTOP-CSC9788:...
```

iPad prompt:

```text
apaches-iPad:~ root#
```

Run `dpkg`, iPad `uicache` and `killall SpringBoard` only after entering the iPad SSH session.

## GitHub

Repository:

```text
SHapeloglu/iPad1FTPDownloader
```

`INTEGRATION.md` is authoritative. `ROADMAP.md`, `TASK.md`, `ARCHITECTURE.md`, `CLAUDE.md` and this session hand-off are aligned to the focused FTP-transfer architecture.
