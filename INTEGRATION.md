# iPad1FTPDownloader Integration Contract

## Purpose

iPad1FTPDownloader is the **FTP specialist** in the iPad 1 application family. It must not evolve into a general HTTP/HTTPS downloader, filesystem manager, media player or PDF reader.

Canonical transfer ownership:

```text
FTP source        -> iPad1FTPDownloader
HTTP/HTTPS source -> iPad1Downloader
local filesystem  -> iPad1Files
video playback    -> iPad1Player
PDF reading       -> iPad1PDFReader
terminal/shell    -> iPad1Terminal
VNC               -> iPad1VNC
```

A media file does not change transfer ownership. If a video is downloaded over FTP, iPad1FTPDownloader owns that transfer. If the same video is downloaded over HTTP/HTTPS, iPad1Downloader owns that transfer. iPad1Player owns only playback of an accessible local media file handed to it after transfer completion.

## Non-negotiable platform constraints

- iPad 1
- 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- non-ARC / MRC
- Theos
- CFNetwork / CFFTP for FTP
- stream-based transfers

## Canonical shared download root

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Create the directory if missing. New FTP downloads must not use `/var/mobile/Media/iPad1FTPDownloads/`.

## Single physical file rule

One transfer produces one physical file. Do not copy a completed download into another app-owned directory merely for integration.

## Download destination behavior

iPad1FTPDownloader owns the destination preference for FTP transfers, while iPad1Files owns the actual folder-picker UI.

Supported preference modes:

```text
Son kullanılan klasör
Her indirmede sor
Her zaman Downloads'a indir
```

The selected folder must remain inside `/var/mobile/Media/iPad1Files/Downloads/` and its descendants.

### Folder picker hand-off

```text
ipad1files://pickFolder?root=<percent-encoded-root>&callback=<percent-encoded-callback>
```

Recommended callback:

```text
ipad1ftp://folderSelected?path=<percent-encoded-absolute-path>
```

FTPDownloader validates the returned path before starting the FTP transfer.

### Future upload picker

```text
ipad1files://pickFile?root=<percent-encoded-root>&callback=<percent-encoded-callback>
```

Callback:

```text
ipad1ftp://fileSelected?path=<percent-encoded-absolute-path>
```

Do not build a second general filesystem browser inside FTPDownloader.

## Completed-file routing

Routing happens only after an FTP transfer finishes successfully and the local file is accessible. The existing absolute local path is handed off; the file is not duplicated.

### Video files

Case-insensitive extensions:

```text
.mkv
.mp4
.mov
.m4v
.avi
```

Offer:

```text
İndirme tamamlandı

iPad1Player ile Aç
Dosyalarda Göster
Tamam
```

Player contract:

```text
ipad1player://open?path=<percent-encoded-absolute-path>
```

FTPDownloader must not decode, render or play video. Codec, seek, subtitle and playback UI remain entirely in iPad1Player.

### PDF files

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

### Other files

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

If a sibling scheme is unavailable, fail gracefully and leave the completed file untouched.

## FTP transfer ownership

The following remain in iPad1FTPDownloader for FTP transfers and must not move to iPad1Player:

- FTP connection and authentication;
- remote directory browsing;
- FTP download/upload;
- FTP transfer queue;
- progress/speed/ETA;
- pause/resume where FTP/server support permits it;
- retry/cancel;
- failed-transfer state and recovery;
- collision handling;
- connection-loss handling;
- remote rename/delete;
- MKD/RMD;
- saved FTP servers;
- remote search/sorting.

Large files must be streamed directly to disk. Whole-file RAM buffering is forbidden. On iPad 1, concurrency must remain deliberately low; prefer a bounded/FIFO model.

## Explicit iPad1Downloader ownership

These do **not** belong in iPad1FTPDownloader:

- generic HTTP download;
- generic HTTPS download;
- browser/web URL download workflows;
- HTTP redirect/cookie/header handling;
- HTTP/HTTPS resume semantics;
- HTTP/HTTPS download queue/retry/failure management.

Those belong to **iPad1Downloader**. iPad1Downloader may use the same completed-file routing contracts to iPad1Player, iPad1PDFReader and iPad1Files, but it owns its own HTTP/HTTPS transfer lifecycle.

## Streaming boundary

Future direct media streaming is not automatically assigned to either Downloader or Player. It must first pass the suite responsibility gate. Do not merge transfer-state ownership with media decode/render ownership merely to add streaming.

## Local browser scope

A lightweight local Downloads view is allowed only for transfer-oriented tasks such as showing FTP transfer results and requesting sibling-app hand-off.

General local filesystem functionality belongs to iPad1Files, including copy/move, folder management, filesystem-wide search, favorites, ZIP/archive, rich preview and Open With behavior.

## Remote path invariant

Every remote FTP directory path must:

```text
start with /
end with /
root is exactly /
```

This invariant applies to manual entry, current state, child navigation, parent navigation, refresh and FTP URL construction.

## Memory policy

Safe:

- streamed FTP download/upload;
- small transfer buffers;
- bounded queue metadata;
- path/preference strings;
- URL-scheme hand-offs.

Use caution:

- simultaneous transfers on iPad 1;
- very long queues;
- recursive remote search;
- heavy secure-protocol libraries.

Do not add:

- whole-file RAM buffering;
- HTTP/HTTPS downloader subsystem;
- video decode/playback;
- PDF rendering;
- OCR;
- AI/ML;
- large background caches;
- SMB expansion;
- heavy SFTP dependencies without physical-device profiling.

## Ownership rule

- FTP transfer / remote FTP operations -> **iPad1FTPDownloader**
- HTTP/HTTPS download -> **iPad1Downloader**
- Local filesystem / picker -> **iPad1Files**
- Video decode / playback / subtitles -> **iPad1Player**
- PDF reading / rendering -> **iPad1PDFReader**
- Terminal / shell -> **iPad1Terminal**
- VNC / remote desktop -> **iPad1VNC**

Integration must use the same physical file path and lightweight hand-offs rather than duplicated files or duplicated subsystems.
