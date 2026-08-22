# SESSION.md

## Latest hand-off

Date: 2026-08-22

## Working context

The project is developed in WSL Ubuntu with Theos for a jailbroken iPad 1 running iOS 5.1.1.

Typical local project path:

```text
~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
```

Latest observed iPad IP:

```text
192.168.1.4
```

The IP can change. Verify before deployment.

## Platform constraints — do not change

- iPad 1
- 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- non-ARC / MRC
- Theos
- CFNetwork / CFFTP
- stream-based transfer

## Confirmed history

### v1.0

Initial FTP downloader built and installed successfully.

### v1.1

Added FTP directory browsing and tap-to-download. Physical-device testing confirmed directory listing and download.

### v1.2

Added upload, saved-server work, transfer progress/speed and remote file-operation infrastructure. Upload progress reached 100% on physical iPad 1.

## Known remote-path bug

On iOS 5 CFNetwork, FTP directory listing may fail unless the remote directory path ends with `/`.

Required invariant:

```text
all remote directories start with / and end with /
root is exactly /
```

An earlier URL-only slash patch was insufficient because internal application state still stored slashless paths. The fix must be centralized and used for manual entry, current-path assignment, child navigation, parent navigation, refresh and FTP URL construction.

## Authoritative integration architecture

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

New downloads go directly to:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Create this directory when missing.

Do not create new downloads under:

```text
/var/mobile/Media/iPad1FTPDownloads/
```

### Single physical file rule

One transferred file = one physical file. Never copy it merely to integrate with iPad1Files or iPad1PDFReader.

## Current v1.3 source state

The prepared v1.3 integration source includes the canonical Downloads root and same-path PDF/iPad1Files completion hand-off code. It must still be treated as **development/unverified** until the exact source builds and passes physical-device testing.

Do not claim a feature works solely because source code exists.

## Newly agreed download destination UX

iPad1FTPDownloader owns the **preference**; iPad1Files owns the actual folder-picker UI.

Planned modes:

```text
Son kullanılan klasör
Her indirmede sor
Her zaman Downloads'a indir
```

When the user chooses another folder, FTPDownloader should call:

```text
ipad1files://pickFolder?root=<encoded-root>&callback=<encoded-callback>
```

Recommended root:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Return callback:

```text
ipad1ftp://folderSelected?path=<percent-encoded-absolute-path>
```

FTPDownloader must validate that the returned path stays under the canonical Downloads root before starting transfer.

The last selected folder may be stored as lightweight metadata. Server-specific last download folder is also acceptable if it remains simple.

## PDF completion UX

When a completed file is `.pdf` (case-insensitive), the desired UI is:

```text
İndirme tamamlandı

PDFReader ile Aç
Dosyalarda Göster
Tamam
```

PDF hand-off:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

iPad1Files hand-off:

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

Same physical path only; no copy.

Planned PDF preference modes:

```text
Her seferinde sor
Otomatik PDFReader ile aç
Sadece indir
```

Recommended default: `Her seferinde sor`.

## Cross-app responsibilities

### Keep in iPad1FTPDownloader

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
- transfer-oriented local results list;
- download-location preference;
- sibling-app path hand-off.

### Delegate to iPad1Files

- folder picker;
- file picker;
- advanced local copy/move;
- general folder management;
- favorites;
- filesystem-wide search;
- classification;
- rich/general preview;
- ZIP/text-editor/Open With features.

### Delegate to iPad1PDFReader

- PDF rendering;
- reader UI;
- PDF-specific navigation/zoom/bookmarks/highlights.

## Sibling app contracts already communicated

### iPad1Files

Expected schemes:

```text
ipad1files://pickFolder?root=...&callback=...
ipad1files://show?path=...
```

Future upload picker:

```text
ipad1files://pickFile?root=...&callback=...
```

Picker must remain constrained to its supplied root.

### iPad1PDFReader

Expected scheme:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

PDFReader must open the same physical file and must work both when cold-launched and when already running.

## Revised roadmap

### v1.3 — integration/stabilization

- canonical Downloads root;
- one-file rule;
- centralized remote path invariant;
- same-path PDF/iPad1Files hand-off;
- download destination preference model;
- keep local UI lightweight;
- build/install/test on physical iPad 1.

### v1.4 — transfer manager

- pause/resume/cancel;
- queue;
- retry;
- progress/speed/ETA;
- overwrite/resume/rename collision handling;
- small metadata-only transfer history.

### v1.5 — FTP remote UX

- saved-server editor;
- remote search;
- sorting/folder-first;
- remote metadata;
- remote-operation polish.

### v1.6 — sibling-app integration polish

- robust picker callback flow;
- robust `Dosyalarda Göster`;
- same-file verification;
- upload-from-iPad1Files hand-in if implemented.

### v1.7 — credential hardening

- iOS-5-compatible Keychain;
- optional no-save-password behavior;
- Anonymous FTP polish.

### SFTP / FTPS

Experimental research only. Do not make them release dependencies. Profile any library on physical iPad 1 before integration.

## Memory policy

Safe:

- streaming transfers;
- small buffers;
- small queue/history metadata;
- small path/preference strings;
- URL scheme hand-offs.

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
- heavy SFTP dependency without profiling.

## Immediate next action

Continue from the actual v1.3 source and implement/verify in this order:

1. confirm canonical download root is used everywhere;
2. confirm the shared Downloads directory is auto-created;
3. centralize and verify remote directory normalization;
4. compile cleanly with legacy Theos/iOS 5 target;
5. install on physical iPad 1;
6. test child and parent navigation with no manual `/` correction;
7. test download/upload/regression features;
8. test PDF completion hand-off;
9. implement the new download destination preference + iPad1Files folder-picker callback;
10. update docs only with physically verified results.

Local build start:

```bash
cd ~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
pwd
ls
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

Latest observed deployment address:

```text
192.168.1.4
```

Example copy:

```bash
scp -o HostKeyAlgorithms=+ssh-rsa \
packages/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb \
root@192.168.1.4:/var/mobile/
```

## Terminal reminder

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
https://github.com/SHapeloglu/iPad1FTPDownloader
```

`SESSION.md` is the primary hand-off document. `INTEGRATION.md` is authoritative for cross-app responsibility and URL-scheme contracts. Physical-device verification is authoritative for feature status.
