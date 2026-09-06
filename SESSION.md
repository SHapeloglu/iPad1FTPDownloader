# SESSION.md

## Latest hand-off

Date: 2026-09-06

## Working context

The project is developed in WSL Ubuntu with Theos for a jailbroken iPad 1 running iOS 5.1.1.

Typical local project path:

```text
~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
```

Current observed iPad IP:

```text
192.168.1.2
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
- CFNetwork / CFFTP for current FTP transport
- stream-based transfer

## Confirmed history

### v1.0

Initial FTP downloader built and installed successfully.

### v1.1

Added FTP directory browsing and tap-to-download. Physical-device testing confirmed directory listing and download.

### v1.2

Added upload, saved-server work, transfer progress/speed and remote file-operation infrastructure. Upload progress reached 100% on physical iPad 1.

### v1.3 current verification

On 2026-08-29 the latest `main` source through commit `a3e9d6a` was pulled, clean-built with the legacy Theos/iOS 5 target and packaged successfully as:

```text
packages/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb
```

The package was installed on the physical iPad 1.

Previously physically verified v1.3 behavior includes:

- entering child directories without manually adding `/`;
- entering nested child directories;
- returning with `← Üst Klasör`;
- repeated parent navigation back to `/`;
- no manual trailing-slash correction during that child/parent flow;
- canonical download root and one-file behavior as tracked in `TASK.md`;
- manual path normalization and independent refresh normalization as tracked in `TASK.md`.

On 2026-08-29, the newly added remote sorting UI was physically tested on the iPad 1 and confirmed working for:

- user-selectable A→Z sorting;
- user-selectable Z→A sorting.

Remote search and the folders-first toggle are source-implemented but still require explicit physical-device verification before being considered working.

## Remote path invariant

Every remote FTP directory path must:

```text
start with /
end with /
root is exactly /
```

The normalization helper is centralized in `FTPPathUtils` and used by the UI/controller and `FTPBrowser` path construction.

## Authoritative integration architecture

iPad1FTPDownloader is the **network-transfer specialist** in the iPad 1 app family. `INTEGRATION.md` is authoritative for cross-app ownership and hand-off contracts.

Canonical completed-download flow:

```text
FTP / future HTTP(S) source
   ↓
iPad1FTPDownloader
   ↓
/var/mobile/Media/iPad1Files/Downloads/
   ↓
file-type hand-off
   ├─ .mkv/.mp4/.mov/.m4v/.avi -> iPad1Player
   ├─ .pdf                     -> iPad1PDFReader
   └─ other                    -> iPad1Files
```

The current implemented transport is FTP through CFNetwork/CFFTP. HTTP/HTTPS downloading is a network-transfer responsibility of Downloader if implemented later, but is not considered implemented or working until source/build/physical-device verification exists.

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

One transferred file = one physical file. Never copy it merely to integrate with iPad1Files, iPad1Player or iPad1PDFReader.

## Media download / Player boundary

Media file downloading remains a Downloader responsibility. Player must not own or duplicate:

- download queue;
- progress;
- pause/resume;
- retry;
- failed-transfer management;
- transfer recovery.

For completed video files with case-insensitive extensions `.mkv`, `.mp4`, `.mov`, `.m4v`, `.avi`, the desired completion action is:

```text
İndirme tamamlandı

iPad1Player ile Aç
Dosyalarda Göster
Tamam
```

Recommended hand-off:

```text
ipad1player://open?path=<percent-encoded-absolute-path>
```

Downloader must pass only a completed, accessible local file path. It must not decode/play media during download. Decode, playback, seek and subtitle handling stay in iPad1Player.

Large files must be streamed to disk, never fully buffered in RAM. Concurrency must remain deliberately low on iPad 1. Future streaming requires a fresh suite responsibility review before implementation so transfer and playback ownership do not become mixed.

## Current v1.3 source state

The current v1.3 source clean-builds and installs on the physical iPad 1. Child/parent navigation, manual path normalization, refresh normalization, canonical-download behavior and A→Z/Z→A remote sorting have physical-device verification recorded in `TASK.md` / this hand-off.

Still unverified in the current build unless separately recorded after this hand-off:

- remote filename/folder search over the already-loaded listing;
- folders-first toggle;
- upload/progress/speed regressions for this exact build;
- saved-server regression;
- remote rename/delete/MKD/RMD regressions for this exact build;
- PDF completion hand-off;
- iPad1Player video completion hand-off (architecturally agreed, source implementation/test pending);
- new download destination preference + iPad1Files folder-picker callback.

Do not claim those features work until tested on the physical device.

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

- FTP connection and remote browse;
- FTP download/upload;
- future HTTP/HTTPS file download transport if later implemented;
- pause/resume/cancel/retry;
- progress/speed/ETA;
- bounded/FIFO queue;
- failed transfer handling;
- saved servers;
- remote search/sort;
- remote rename/delete;
- MKD/RMD;
- transfer-oriented local results list;
- download-location preference;
- completed-file sibling-app path hand-off.

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

### Delegate to iPad1Player

- video decode/playback;
- seek/playback controls;
- codec/media-rendering behavior;
- subtitle discovery/rendering.

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

### iPad1Player

Expected scheme:

```text
ipad1player://open?path=<percent-encoded-absolute-path>
```

Player must open the same completed physical file and must work both when cold-launched and when already running. It must not absorb Downloader transfer state/queue/retry logic.

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
- add same-path iPad1Player hand-off for completed video files;
- download destination preference model;
- keep local UI lightweight;
- build/install/test on physical iPad 1.

### v1.4 — transfer manager

- pause/resume/cancel;
- queue;
- retry;
- progress/speed/ETA;
- overwrite/resume/rename collision handling;
- failed-download management;
- small metadata-only transfer history;
- deliberately low concurrency on iPad 1.

### v1.5 — FTP remote UX

- saved-server editor;
- remote search;
- sorting/folder-first;
- remote metadata;
- remote-operation polish.

### v1.6 — sibling-app integration polish

- robust picker callback flow;
- robust `Dosyalarda Göster`;
- robust iPad1Player / iPad1PDFReader same-file hand-off;
- same-file verification;
- upload-from-iPad1Files hand-in if implemented.

### v1.7 — credential hardening

- iOS-5-compatible Keychain;
- optional no-save-password behavior;
- Anonymous FTP polish.

### HTTP / HTTPS download transport

Network-transfer scope if implemented later. Must use stream-to-disk behavior and pass physical iPad testing; do not claim support from architecture alone.

### Streaming

Not automatically approved. Must first pass the suite responsibility filter and preserve a clean network-transfer vs media-playback boundary.

### SFTP / FTPS

Experimental research only. Do not make them release dependencies. Profile any library on physical iPad 1 before integration.

## Memory policy

Safe:

- streaming transfers directly to disk;
- small buffers;
- small queue/history metadata;
- small path/preference strings;
- URL scheme hand-offs.

Use caution:

- simultaneous downloads on iPad 1;
- recursive remote search;
- very long queues;
- heavy secure-protocol libraries.

Do not add:

- whole-file RAM buffering;
- video decode/playback in Downloader;
- rich local preview framework;
- OCR;
- AI/ML;
- large background caches;
- SMB expansion;
- heavy SFTP dependency without profiling.

## Immediate next action

Continue from the physically installed current v1.3 build and verify in this order:

1. test remote filename/folder search over the current loaded directory listing;
2. test the folders-first toggle in both states and after changing remote directory;
3. test upload/progress/speed and saved-server regressions;
4. test rename/delete/MKD/RMD regressions;
5. implement and then physically test completed-video iPad1Player hand-off without changing transfer ownership;
6. test PDF completion hand-off;
7. implement the new download destination preference + iPad1Files folder-picker callback;
8. update docs only with physically verified results.

## Deployment

Current observed iPad address:

```text
192.168.1.2
```

Example copy:

```bash
scp -o HostKeyAlgorithms=+ssh-rsa \
-o PubkeyAcceptedAlgorithms=+ssh-rsa \
packages/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb \
root@192.168.1.2:/var/mobile/
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
