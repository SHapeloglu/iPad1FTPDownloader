# iPad1FTPDownloader Integration Contract

## Purpose

iPad1FTPDownloader is the **network-transfer specialist** in the iPad 1 application family. It must not evolve into a general filesystem manager or a PDF reader.

The intended flow is:

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

## Shared download root

Canonical FTP download directory:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

iPad1FTPDownloader must create the directory if it does not exist.

The old directory:

```text
/var/mobile/Media/iPad1FTPDownloads/
```

is deprecated and must not be used for new downloads.

## Single physical file rule

A transferred file must have one canonical physical location.

Correct:

```text
/var/mobile/Media/iPad1Files/Downloads/example.pdf
```

Incorrect:

```text
/var/mobile/Media/iPad1FTPDownloads/example.pdf
/var/mobile/Media/iPad1Files/Downloads/example.pdf
```

Do not copy a completed FTP download into iPad1Files. Download it directly into the shared directory.

## PDF hand-off

When a completed download has a `.pdf` extension, the UI may offer:

```text
Download complete

PDFReader ile Aç
Dosyalarda Göster
Tamam
```

PDFReader URL scheme:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

The file must be opened from the existing physical path. Do not duplicate it.

## iPad1Files hand-off

Optional URL scheme:

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

This is a hand-off only. iPad1FTPDownloader must not implement iPad1Files functionality merely because the URL scheme is not yet available.

## Local browser scope

A lightweight local Downloads view is allowed for transfer-oriented tasks:

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
- Open With registry.

## FTP-owned functionality

These features stay in iPad1FTPDownloader:

- FTP connection;
- remote folder browsing;
- download;
- upload;
- pause/resume;
- transfer progress;
- transfer speed;
- FIFO transfer queue;
- remote rename;
- delete;
- MKD/RMD;
- saved servers;
- remote search;
- sorting.

Do not move these responsibilities into iPad1Files or iPad1PDFReader.

## Remote path invariant

Every remote FTP directory path must:

1. start with `/`;
2. end with `/`.

Correct:

```text
/domains/example.com/public_html/css/
```

Incorrect:

```text
domains/example.com/public_html/css
/domains/example.com/public_html/css
```

This invariant must hold for:

- manually entered paths;
- current path state;
- child-directory navigation;
- parent-directory navigation;
- refresh;
- URL construction.

Normalize before storing directory state, not only immediately before a network request.

## Memory policy

### Safe

- streamed download/upload;
- small transfer buffers;
- FIFO queue metadata;
- URL/path hand-offs.

### Use caution

- large previews;
- very long queues;
- recursive remote search.

### Do not add

- loading complete transferred files into RAM;
- heavy SMB/SFTP libraries without profiling on the physical iPad 1;
- OCR;
- AI/ML;
- large background caches.

## Architectural decision rule

If a feature is primarily about **network transfer**, it belongs here.

If it is primarily about **general local file management**, it belongs in iPad1Files.

If it is primarily about **reading/rendering PDFs**, it belongs in iPad1PDFReader.

Integration should use a shared physical path and lightweight URL-scheme hand-offs rather than file duplication or duplicated feature sets.
