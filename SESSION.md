# SESSION.md

## Latest hand-off

Date: 2026-09-16

## Product identity

The active source base is still hosted at:

```text
https://github.com/SHapeloglu/iPad1FTPDownloader
```

but the application/package is now being migrated to:

```text
iPad1Downloader
com.olap.ipad1downloader
v1.4.0
```

The separate `SHapeloglu/ipad1HTTPDownloader` repository is currently empty and is not the active implementation base.

## Platform constraints — do not change

- iPad 1
- Apple A4
- ~256 MB RAM
- iOS 5.1.1
- armv7
- Objective-C
- non-ARC / MRC
- Theos
- legacy iPhoneOS 6.1 SDK
- stream-to-disk for large transfers
- physical-device behavior is authoritative

## Unified transport architecture

`iPad1Downloader` owns network transfer only:

```text
FTP        -> existing FTP engine
HTTP/HTTPS -> HTTPDownloadTask
Wi-Fi Al   -> WiFiReceiveServer
```

The unified UI uses three tabs:

```text
FTP | HTTP | Wi-Fi Al
```

FTP protocol code, HTTP protocol code and Wi-Fi receive code remain separate engines.

## iPad1Files ownership boundary

Do NOT implement these inside Downloader:

- local filesystem browser;
- destination folder browser/picker;
- local copy/move/rename/delete;
- ZIP/archive;
- local search/favorites;
- downloaded-file organization;
- general Open With / file manager UI.

Those belong to `iPad1Files`.

Canonical destination while the external picker is not yet physically verified:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

One transfer = one physical file.

## Existing FTP historical verification

Previously physically verified on iPad 1:

- FTP connection/browse/download basics;
- child/nested directory navigation;
- parent navigation;
- canonical download root behavior tracked in prior tests;
- A->Z remote sorting;
- Z->A remote sorting;
- an earlier upload/progress flow reached 100%.

These are historical FTP-core results. They do not automatically verify the new unified v1.4 package.

## v1.4 source implemented — physical test pending

### HTTP/HTTPS

Implemented in source:

- `HTTPDownloadTask`;
- HTTP and HTTPS URL validation;
- `NSURLConnection` GET transport;
- normal redirect handling through `NSURLConnection`;
- non-2xx HTTP rejection;
- `NSURLResponse suggestedFilename` with URL fallback;
- safe filename normalization;
- unique-name collision handling;
- `<filename>.part` temporary file;
- chunk-by-chunk disk write;
- progress;
- speed;
- cancel;
- completion hand-off to PDFReader / Player / Files.

Not yet implemented/verified:

- HTTP Range resume;
- 206 validation;
- retry policy;
- network-loss automatic recovery;
- bounded unified queue;
- ETA smoothing.

### Windows -> iPad Wi-Fi Receive

Implemented in source:

- lightweight local TCP/HTTP receive server;
- port 8080;
- listens only while the user enables the receiver;
- local Wi-Fi IP discovery via `en0`;
- six-digit per-start session token;
- tiny browser upload page;
- browser sends raw file body with HTTP PUT;
- no multipart parser;
- `Content-Length` required;
- filename sanitization and collision-safe naming;
- `.part` streamed write;
- final rename on complete receipt;
- one connection/transfer processed at a time;
- partial file retained when transfer is interrupted.

Files are received only into:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

Local browsing after transfer remains an `iPad1Files` responsibility.

## Source files added for v1.4

```text
src/UnifiedAppDelegate.h
src/UnifiedAppDelegate.m
src/HTTPDownloadTask.h
src/HTTPDownloadTask.m
src/HTTPDownloadViewController.h
src/HTTPDownloadViewController.m
src/WiFiReceiveServer.h
src/WiFiReceiveServer.m
src/WiFiReceiveViewController.h
src/WiFiReceiveViewController.m
```

Changed:

```text
src/main.m
Makefile
Info.plist
control
README.md
```

## Build status

**PASS — 2026-09-16**

WSL/Theos clean package build completed successfully for armv7 / iOS 5.1 target.

Observed build sequence:

```text
Making all for application iPad1Downloader
Compiling FTP sources
Compiling HTTPDownloadTask / HTTPDownloadViewController
Compiling WiFiReceiveServer / WiFiReceiveViewController
Linking application iPad1Downloader (armv7)
Signing iPad1Downloader
Packaging com.olap.ipad1downloader_1.4.0_iphoneos-arm.deb
```

Generated package:

```text
packages/com.olap.ipad1downloader_1.4.0_iphoneos-arm.deb
```

Only warning observed:

```text
ld: warning: building for iOS 5.1.0 is deprecated
```

This warning is expected for the legacy target and did not block packaging.

The package itself is build-verified but **not yet physically verified on iPad 1**.

## Immediate next action

Test in this order:

1. install `com.olap.ipad1downloader_1.4.0_iphoneos-arm.deb` on the physical iPad 1;
2. launch and confirm the three tabs appear: FTP / HTTP / Wi-Fi Al;
3. confirm FTP tab still connects/lists/navigates;
4. test a small plain HTTP file;
5. test an HTTPS URL compatible with the iOS 5 TLS stack;
6. test an HTTP redirect;
7. cancel an HTTP download and inspect `.part` behavior;
8. start `Wi-Fi Al` and confirm the iPad local URL is shown;
9. from Windows on the same LAN, open the URL and upload a small file;
10. upload a larger file while watching iPad memory/stability;
11. verify the final file exists in `iPad1Files/Downloads`;
12. only after physical confirmation update feature status to verified.

## Cross-app completion contracts

```text
PDF   -> ipad1pdf://open?path=<encoded-absolute-path>
video -> ipad1player://open?path=<encoded-absolute-path>
other -> ipad1files://show?path=<encoded-absolute-path>
```

Never duplicate a file solely for hand-off.

## Memory policy

Allowed:

- small network buffers;
- direct stream-to-disk;
- `.part` files;
- small bounded metadata;
- one active large transfer preferred.

Forbidden inside Downloader:

- whole-file RAM buffering;
- embedded local file manager;
- embedded PDF engine;
- embedded media player/codec stack;
- OCR/AI/ML;
- large caches;
- uncontrolled parallel transfers.

`INTEGRATION.md` remains authoritative for suite responsibility boundaries.
