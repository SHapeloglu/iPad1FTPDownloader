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
- CFNetwork / CFFTP
- stream-based FTP transfer

## Authoritative ownership decision

`INTEGRATION.md` is authoritative for cross-app responsibility.

```text
FTP transfer / remote FTP operations -> iPad1FTPDownloader
HTTP/HTTPS download                 -> iPad1Downloader
Local filesystem / picker           -> iPad1Files
Video playback / codecs / subtitles -> iPad1Player
PDF reading / rendering             -> iPad1PDFReader
Terminal / shell                     -> iPad1Terminal
VNC / remote desktop                 -> iPad1VNC
```

A media file does not change transfer ownership. FTP media files are downloaded by iPad1FTPDownloader; HTTP/HTTPS media files are downloaded by iPad1Downloader. iPad1Player receives only a completed accessible local path.

## Confirmed history

### v1.0

Initial FTP downloader built and installed successfully.

### v1.1

Added FTP directory browsing and tap-to-download. Physical-device testing confirmed directory listing and download.

### v1.2

Added upload, saved-server work, transfer progress/speed and remote file-operation infrastructure. Upload progress reached 100% on physical iPad 1.

### v1.3 current verification

On 2026-08-29 `main` through commit `a3e9d6a` was pulled, clean-built and packaged successfully as:

```text
packages/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb
```

The package was installed on the physical iPad 1.

Physically verified behavior includes:

- child and nested directory navigation without manual slash correction;
- parent navigation back to `/`;
- centralized path normalization behavior tracked in `TASK.md`;
- canonical download root / one-file behavior tracked in `TASK.md`;
- A→Z remote sorting;
- Z→A remote sorting.

Remote search and folders-first are source-implemented but still need explicit physical-device verification.

## Remote path invariant

Every remote FTP directory path must:

```text
start with /
end with /
root is exactly /
```

The normalization helper is centralized in `FTPPathUtils`.

## Canonical FTP download flow

```text
FTP Server
   ↓
iPad1FTPDownloader
   ↓
/var/mobile/Media/iPad1Files/Downloads/
   ↓
completed-file hand-off
   ├─ .mkv/.mp4/.mov/.m4v/.avi -> iPad1Player
   ├─ .pdf                     -> iPad1PDFReader
   └─ other                    -> iPad1Files
```

There is **no HTTP/HTTPS transport roadmap inside this repository**. Generic HTTP/HTTPS download belongs to iPad1Downloader.

## Canonical download root

New FTP downloads go directly to:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Do not create new downloads under `/var/mobile/Media/iPad1FTPDownloads/`.

One transfer = one physical file. Do not duplicate a completed file merely for Player, PDFReader or Files integration.

## Completed video hand-off

For successful FTP downloads ending case-insensitively in:

```text
.mkv .mp4 .mov .m4v .avi
```

the desired completion UX is:

```text
İndirme tamamlandı

iPad1Player ile Aç
Dosyalarda Göster
Tamam
```

Player hand-off:

```text
ipad1player://open?path=<percent-encoded-absolute-path>
```

FTPDownloader must pass only a completed accessible local path. It must not decode, render, seek, inspect subtitles or play media.

## Transfer ownership

FTPDownloader retains FTP-specific:

- connection/authentication;
- remote browse;
- download/upload;
- queue;
- progress/speed/ETA;
- pause/resume/cancel/retry;
- failed-transfer management;
- connection-loss recovery;
- remote rename/delete/MKD/RMD;
- saved FTP servers;
- remote search/sort.

Large files must be streamed to disk. Whole-file RAM buffering is forbidden. Concurrency should remain deliberately low; preferred initial model is one active FTP transfer plus bounded FIFO metadata.

## Explicit iPad1Downloader delegation

Do not add these to iPad1FTPDownloader:

- HTTP downloads;
- HTTPS downloads;
- browser URL download workflows;
- redirect/cookie/header handling;
- HTTP/HTTPS resume semantics;
- HTTP/HTTPS queue/retry/failure management.

The iPad1Downloader application should own those and may reuse the same completed-file routing contracts.

## Download destination UX

iPad1FTPDownloader owns FTP destination preference; iPad1Files owns the actual folder picker.

Planned modes:

```text
Son kullanılan klasör
Her indirmede sor
Her zaman Downloads'a indir
```

Folder picker:

```text
ipad1files://pickFolder?root=<encoded-root>&callback=<encoded-callback>
```

Callback:

```text
ipad1ftp://folderSelected?path=<percent-encoded-absolute-path>
```

Returned paths must remain under the canonical Downloads root.

## PDF completion UX

For `.pdf`:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

For Files:

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

All actions use the same physical file.

## Current source/test state

Physically verified:

- current v1.3 clean build/install;
- child/parent navigation;
- path normalization items already checked in `TASK.md`;
- canonical download root / one-file behavior tracked in `TASK.md`;
- A→Z sorting;
- Z→A sorting.

Still unverified unless later recorded:

- remote filename/folder search;
- folders-first toggle;
- upload/progress/speed regressions in this exact build;
- saved-server regression;
- rename/delete/MKD/RMD regressions;
- PDF completion hand-off;
- iPad1Player completion hand-off;
- destination preference + iPad1Files folder-picker callback.

Do not claim unverified features work until physical iPad testing passes.

## Streaming boundary

Future direct media streaming is not automatically a FTPDownloader or Player feature. Run the suite responsibility filter first and preserve separate transport and decode/render ownership.

## Memory policy

Safe:

- FTP stream-to-disk;
- small buffers;
- bounded queue/history metadata;
- path/preference strings;
- URL-scheme hand-offs.

Do not add:

- whole-file RAM buffering;
- HTTP/HTTPS downloader subsystem;
- video playback/codec/subtitle engine;
- rich local preview framework;
- PDF rendering;
- OCR;
- AI/ML;
- large background caches;
- SMB expansion;
- heavy SFTP dependency without profiling.

## Immediate next action

Continue from the physically installed current v1.3 build and verify in this order:

1. test remote filename/folder search over the current loaded directory listing;
2. test folders-first in both states and after changing remote directory;
3. test upload/progress/speed and saved-server regressions;
4. test rename/delete/MKD/RMD regressions;
5. implement and physically test completed-video `iPad1Player ile Aç` hand-off for FTP-downloaded video files;
6. test PDF completion hand-off;
7. implement destination preference + iPad1Files folder-picker callback;
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

## GitHub

Repository:

```text
https://github.com/SHapeloglu/iPad1FTPDownloader
```

`SESSION.md` is the primary hand-off document. `INTEGRATION.md` is authoritative for cross-app responsibility. Physical-device verification is authoritative for feature status.
