# iPad1FTPDownloader Integration Contract

## Purpose

iPad1FTPDownloader is the **network-transfer specialist** in the iPad 1 application family. It must not evolve into a general filesystem manager, media player or PDF reader.

Canonical flow:

```text
FTP / future HTTP(S) source
   ↓
iPad1FTPDownloader
   ↓
/var/mobile/Media/iPad1Files/Downloads/
   ↓
file-type hand-off
   ├─ video -> iPad1Player
   ├─ PDF   -> iPad1PDFReader
   └─ other -> iPad1Files
```

The current implemented transport remains CFNetwork/CFFTP. HTTP/HTTPS download is an iPad1FTPDownloader/network-transfer responsibility if added later, but must not be claimed as implemented until source, build and physical iPad verification exist.

## Non-negotiable platform constraints

- iPad 1
- 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- non-ARC / MRC
- Theos
- CFNetwork / CFFTP for the current FTP implementation
- stream-based transfers

## Canonical shared download root

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Create the directory if missing. New downloads must not use `/var/mobile/Media/iPad1FTPDownloads/`.

## Single physical file rule

One transfer produces one physical file. Do not copy a completed download into another app-owned directory for integration.

## Download destination behavior

iPad1FTPDownloader owns the download-location **preference**, while iPad1Files owns the real folder-picker UI.

Supported preference modes:

```text
Son kullanılan klasör
Her indirmede sor
Her zaman Downloads'a indir
```

The selected folder must remain inside:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

and its descendants.

### Folder picker hand-off

When the user chooses `Başka klasör seç`, call iPad1Files:

```text
ipad1files://pickFolder?root=<percent-encoded-root>&callback=<percent-encoded-callback>
```

Recommended root:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Recommended callback:

```text
ipad1ftp://folderSelected?path=<percent-encoded-absolute-path>
```

The downloader validates the returned path is still under the canonical Downloads root before starting the transfer.

The last selected folder may be persisted as a small path string. Server-specific last-folder metadata is allowed if useful and kept lightweight.

### Future upload picker

A future upload may use:

```text
ipad1files://pickFile?root=<percent-encoded-root>&callback=<percent-encoded-callback>
```

with callback:

```text
ipad1ftp://fileSelected?path=<percent-encoded-absolute-path>
```

Do not build a second general filesystem browser inside FTPDownloader.

## Completion routing by file type

Routing happens only **after a transfer completes successfully** and the local file is accessible. Downloader passes the existing absolute local path; it does not duplicate the file.

### Video

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

Recommended Player hand-off contract:

```text
ipad1player://open?path=<percent-encoded-absolute-path>
```

iPad1FTPDownloader must not decode, probe deeply, render or play video during download. Playback, codecs, subtitle discovery and media UI belong to iPad1Player.

### PDF

When a completed file extension is `.pdf` (case-insensitive), offer:

```text
İndirme tamamlandı

PDFReader ile Aç
Dosyalarda Göster
Tamam
```

PDFReader hand-off:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

### Other files

Use iPad1Files:

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

All completion actions use the same physical file; never copy it merely for integration.

### PDF post-download preference

Support these lightweight modes:

```text
Her seferinde sor
Otomatik PDFReader ile aç
Sadece indir
```

Recommended initial/default behavior is `Her seferinde sor` until physical-device UX testing says otherwise.

If a sibling URL scheme is unavailable, fail gracefully and leave the downloaded file untouched.

## Transfer ownership

Transfer mechanics remain in iPad1FTPDownloader and must not move to iPad1Player:

- download queue;
- progress;
- speed / ETA;
- pause/resume;
- retry;
- cancellation;
- failed-transfer state and recovery;
- collision handling;
- connection-loss recovery.

Large media files must be streamed to disk. Whole-file buffering in RAM is forbidden. On iPad 1, keep concurrency deliberately low; prefer a bounded/FIFO transfer model over many simultaneous transfers.

## Streaming boundary

Future media streaming is not automatically a Downloader or Player feature merely because competitors provide it. Before any streaming design or implementation, run the suite responsibility gate and define a narrow contract between network transport and playback. Do not merge the Downloader transfer engine with Player decode/render responsibilities.

## Local browser scope

A lightweight local Downloads view is allowed only for transfer-oriented tasks:

- list completed downloads;
- show transfer result;
- open/hand off a downloaded file.

General filesystem features belong to iPad1Files:

- advanced copy/move;
- general folder management;
- favorites;
- filesystem-wide search;
- file classification;
- rich/general preview system;
- ZIP/text-editor features;
- Open With registry.

## Network-transfer-owned functionality

These remain in iPad1FTPDownloader:

- FTP connection and remote folder browsing;
- FTP download/upload;
- future HTTP/HTTPS file download transport if implemented;
- pause/resume/cancel/retry;
- transfer progress/speed/ETA;
- FIFO/bounded queue;
- failed transfer handling;
- remote rename/delete;
- MKD/RMD;
- saved servers;
- remote search;
- sorting;
- completed-file sibling-app hand-off.

## Remote path invariant

Every remote FTP **directory** path must start with `/` and end with `/`. Root is exactly `/`.

Correct:

```text
/domains/example.com/public_html/css/
```

This invariant applies to manual entry, current state, child navigation, parent navigation, refresh and FTP URL construction. Normalize before storing directory state, not only before a network request.

## Memory policy

Safe:

- streamed download/upload;
- small transfer buffers;
- FIFO/bounded queue metadata;
- saved path/preference strings;
- URL/path hand-offs.

Use caution:

- simultaneous transfers on iPad 1;
- very long queues;
- recursive remote search;
- heavy secure-protocol libraries.

Do not add:

- whole-file RAM buffering;
- video decode/playback in Downloader;
- PDF rendering in Downloader;
- OCR;
- AI/ML;
- large background caches;
- heavy SMB/SFTP dependencies without profiling on physical iPad 1.

## Ownership rule

- Network transfer, including media file download → **iPad1FTPDownloader**
- Local filesystem/folder-picker problem → **iPad1Files**
- Video decode/playback/subtitles → **iPad1Player**
- PDF reading/rendering → **iPad1PDFReader**
- Terminal/shell → **iPad1Terminal**
- VNC/remote desktop → **iPad1VNC**

Integration must use shared physical paths and lightweight URL-scheme hand-offs rather than duplicate files or duplicate subsystems.
