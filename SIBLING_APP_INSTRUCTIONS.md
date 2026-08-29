# SIBLING_APP_INSTRUCTIONS.md

## Purpose

This document defines work discovered while reviewing iPad1FTPDownloader that belongs to sibling specialist applications. Do not reimplement these capabilities inside iPad1FTPDownloader.

## Mandatory ownership gate

Before implementing any feature, determine its primary owner:

- FTP/network transfer -> iPad1FTPDownloader
- local filesystem, folder/file picking, copy/move, ZIP, general preview -> iPad1Files
- PDF rendering/reading/annotation -> iPad1PDFReader
- shell/terminal/command execution -> iPad1Terminal
- VNC/remote desktop -> iPad1VNC

If another application owns the capability, integrate by shared physical path and a lightweight URL-scheme hand-off. Do not duplicate the subsystem.

---

## iPad1Files instructions

### 1. Folder picker

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
- work when cold-launched and when already running;
- preserve iPad 1 / iOS 5.1.1 / armv7 / MRC compatibility.

### 2. File picker for FTP upload

The current FTPDownloader still has a temporary local Downloads chooser for upload. Replace that ownership with an iPad1Files picker contract before removing the fallback.

Recommended contract:

```text
ipad1files://pickFile?root=<percent-encoded-root>&callback=<percent-encoded-callback>
```

Callback:

```text
ipad1ftp://fileSelected?path=<percent-encoded-absolute-path>
```

Requirements:

- iPad1Files owns all local browsing UI;
- FTPDownloader receives only the selected path and performs streamed upload;
- do not duplicate files;
- reject inaccessible/non-file results cleanly;
- keep picker memory usage bounded.

### 3. Show downloaded file

Support:

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

The same physical file under the shared filesystem must be shown. No copy is allowed.

### 4. Features that stay entirely in iPad1Files

- local copy/move;
- folder management;
- local search;
- favorites/tags/classification;
- ZIP/archive management;
- image/general file preview;
- general Open With behavior;
- broad local file metadata UI.

---

## iPad1PDFReader instructions

Support:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Requirements:

- open the same physical downloaded PDF;
- work both cold and warm launch;
- rendering, zoom, page navigation, bookmark and highlight behavior stay entirely in iPad1PDFReader;
- FTPDownloader must never embed PDF rendering or make a duplicate PDF copy.

---

## iPad1Terminal instructions

Terminal and shell execution are outside FTPDownloader scope.

If a future workflow needs to pass a downloaded script or remote-host context to Terminal, define a narrow hand-off contract in iPad1Terminal. FTPDownloader must not embed a shell, pseudo-terminal, SSH console or command interpreter.

Potential future path hand-off, only after Terminal explicitly supports it:

```text
ipad1terminal://open?path=<percent-encoded-absolute-path>
```

Do not implement this scheme in FTPDownloader until the Terminal application owns and documents the receiving contract.

---

## iPad1VNC instructions

VNC/remote desktop is outside FTPDownloader scope.

If a saved FTP host is also used for VNC, a future integration may pass host metadata to iPad1VNC. FTPDownloader must not embed framebuffer, VNC protocol or remote-desktop UI.

Any future scheme must be defined first by iPad1VNC and should pass only lightweight connection metadata, never duplicate VNC logic inside FTPDownloader.

---

## Removal rule

A temporary fallback inside FTPDownloader may remain only until the owning sibling app has a physically verified receiving contract. Once the hand-off is verified on iPad 1, remove the duplicate fallback from FTPDownloader.

Physical-device behavior is authoritative.
