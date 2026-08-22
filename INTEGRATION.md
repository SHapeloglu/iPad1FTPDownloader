# iPad1FTPDownloader Integration Contract

## Purpose

iPad1FTPDownloader is the **network-transfer specialist** in the iPad 1 application family. It must not evolve into a general filesystem manager or a PDF reader.

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

## Non-negotiable platform constraints

- iPad 1
- 256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- non-ARC / MRC
- Theos
- CFNetwork / CFFTP
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

The FTP app validates the returned path is still under the canonical Downloads root before starting the transfer.

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

## PDF completion behavior

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

iPad1Files hand-off:

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

Both actions use the same physical file; never copy it.

### PDF post-download preference

Support these lightweight modes:

```text
Her seferinde sor
Otomatik PDFReader ile aç
Sadece indir
```

Recommended initial/default behavior is `Her seferinde sor` until physical-device UX testing says otherwise.

If a sibling URL scheme is unavailable, fail gracefully and leave the downloaded file untouched.

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

## FTP-owned functionality

These remain in iPad1FTPDownloader:

- FTP connection;
- remote folder browsing;
- download/upload;
- pause/resume/cancel/retry;
- transfer progress/speed/ETA;
- FIFO queue;
- remote rename/delete;
- MKD/RMD;
- saved servers;
- remote search;
- sorting.

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
- FIFO queue metadata;
- saved path/preference strings;
- URL/path hand-offs.

Use caution:

- very long queues;
- recursive remote search;
- heavy secure-protocol libraries.

Do not add:

- whole-file RAM buffering;
- OCR;
- AI/ML;
- large background caches;
- heavy SMB/SFTP dependencies without profiling on physical iPad 1.

## Ownership rule

- Network transfer problem → **iPad1FTPDownloader**
- Local filesystem/folder-picker problem → **iPad1Files**
- PDF reading/rendering problem → **iPad1PDFReader**

Integration must use shared physical paths and lightweight URL-scheme hand-offs rather than duplicate files or duplicate subsystems.
