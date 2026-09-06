# SIBLING_APP_INSTRUCTIONS.md

## Purpose

This document defines work discovered while reviewing iPad1FTPDownloader that belongs to sibling specialist applications. Do not reimplement these capabilities inside iPad1FTPDownloader.

## Mandatory ownership gate

Before implementing any feature, determine its primary owner:

- FTP transfer / remote FTP operations -> iPad1FTPDownloader
- HTTP/HTTPS downloads -> iPad1Downloader
- local filesystem, folder/file picking, copy/move, ZIP, general preview -> iPad1Files
- video decode/playback/subtitle handling -> iPad1Player
- PDF rendering/reading/annotation -> iPad1PDFReader
- shell/terminal/command execution -> iPad1Terminal
- VNC/remote desktop -> iPad1VNC

If another application owns the capability, integrate by shared physical path and a lightweight URL-scheme hand-off. Do not duplicate the subsystem.

---

## iPad1Downloader instructions

HTTP/HTTPS downloading belongs here, not in iPad1FTPDownloader.

Expected ownership:

- generic HTTP downloads;
- generic HTTPS downloads;
- browser/web URL download workflows;
- redirects;
- cookies/headers where required by download transport;
- HTTP/HTTPS resume semantics;
- HTTP/HTTPS queue/progress/retry/failure management;
- stream-to-disk behavior for large files;
- deliberately low concurrency on iPad 1.

Recommended completed-file routing should mirror the suite contracts:

```text
.mkv/.mp4/.mov/.m4v/.avi -> ipad1player://open?path=...
.pdf                     -> ipad1pdf://open?path=...
other                    -> ipad1files://show?path=...
```

Only completed, accessible local file paths should be handed to sibling apps. Do not copy files merely for integration.

---

## iPad1Files instructions

### Folder picker

Provide:

```text
ipad1files://pickFolder?root=<percent-encoded-root>&callback=<percent-encoded-callback>
```

FTPDownloader will normally supply:

```text
root=/var/mobile/Media/iPad1Files/Downloads/
callback=ipad1ftp://folderSelected?path=...
```

Requirements:

- picker must stay inside the supplied root;
- return an absolute canonical path;
- do not copy the selected folder or transferred file;
- work cold and warm launch;
- preserve iPad 1 / iOS 5.1.1 / armv7 / MRC compatibility.

### File picker for FTP upload

Recommended contract:

```text
ipad1files://pickFile?root=<percent-encoded-root>&callback=<percent-encoded-callback>
```

Callback:

```text
ipad1ftp://fileSelected?path=<percent-encoded-absolute-path>
```

Requirements:

- iPad1Files owns local browsing UI;
- FTPDownloader receives only the selected path and performs streamed FTP upload;
- do not duplicate files;
- reject inaccessible/non-file results cleanly;
- keep picker memory usage bounded.

### Show downloaded file

Support:

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

The same physical file must be shown. No copy is allowed.

### Features that stay entirely in iPad1Files

- local copy/move;
- folder management;
- local search;
- favorites/tags/classification;
- ZIP/archive management;
- image/general file preview;
- general Open With behavior;
- broad local file metadata UI.

---

## iPad1Player instructions

Support the completed-file hand-off contract:

```text
ipad1player://open?path=<percent-encoded-absolute-path>
```

FTPDownloader may call it only after a successful FTP download for these case-insensitive extensions:

```text
.mkv
.mp4
.mov
.m4v
.avi
```

Requirements:

- open the same physical completed file; no copy;
- work both cold and warm launch;
- accept an accessible local path only;
- media decode, playback UI, seeking, codec behavior and subtitle discovery/rendering stay entirely in iPad1Player;
- Player must not own FTPDownloader queue, progress, pause/resume, retry, cancellation or failed-transfer management;
- Player must not own iPad1Downloader HTTP/HTTPS transfer lifecycle either;
- FTPDownloader must not decode or play video while a transfer is in progress.

Future streaming requires a separate suite responsibility review. Do not merge downloader transfer state with Player decode/render state.

---

## iPad1PDFReader instructions

Support:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Requirements:

- open the same physical completed PDF;
- work cold and warm launch;
- rendering, zoom, page navigation, bookmark and highlight behavior stay entirely in iPad1PDFReader;
- downloader apps must never embed PDF rendering or create a duplicate PDF copy for hand-off.

---

## iPad1Terminal instructions

Terminal and shell execution are outside FTPDownloader scope. Any future path/host hand-off must be defined first by iPad1Terminal.

---

## iPad1VNC instructions

VNC/remote desktop is outside FTPDownloader scope. Any future host-context hand-off must be defined first by iPad1VNC.

---

## Transfer constraints relevant to downloader apps

- completed files are handed off by path only;
- large files are streamed to disk rather than buffered in RAM;
- iPad 1 concurrency remains deliberately low;
- queue/progress/pause-resume/retry/failure handling stays with the downloader that owns the transport;
- sibling reader/player apps receive only completed accessible files unless a separately approved streaming contract exists.

## Removal rule

A temporary fallback inside FTPDownloader may remain only until the owning sibling app has a physically verified receiving contract. Once the hand-off is verified on iPad 1, remove duplicate fallback behavior where appropriate.

Physical-device behavior is authoritative.
