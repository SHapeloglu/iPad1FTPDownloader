# CHANGELOG.md

All notable project changes should be recorded here.

## [Unreleased] — v1.3 development

### Added / prepared

- Central directory path normalization design.
- Local Downloads browser.
- Remote search.
- A→Z / Z→A sorting.
- Basic text/image/HTML/PDF preview infrastructure.
- Download pause/resume infrastructure.
- FTP transfer offset/resume support where server and CFNetwork allow it.
- Transfer queue infrastructure.
- Secure-transport abstraction/integration points for future SFTP/FTPS work.

### Important

v1.3 features are development work until the exact source successfully builds and passes physical iPad 1 testing.

## [1.2.0]

### Added

- Saved FTP server support.
- Upload support.
- Remote rename infrastructure.
- Remote delete infrastructure.
- New-folder infrastructure.
- Transfer progress UI.
- Percentage display.
- Transfer speed display.
- Human-readable remote file-size display.

### Verified observations

- v1.2 built and installed on iPad 1.
- Upload reached 100% during device testing.
- Transfer speed/progress was displayed.

### Known issue discovered

Directory navigation on legacy iOS 5 CFNetwork may fail if a directory path does not end with `/`.

An initial attempt to append `/` only while building the network URL did not fully solve the issue because application navigation state still stored non-normalized paths.

## [1.1.0]

### Added

- FTP directory listing.
- Folder navigation.
- Parent-folder navigation.
- Tap-to-download file browser.

### Verified

Directory listing and file download worked on the physical iPad 1.

## [1.0.0]

### Added

- Initial FTP downloader.
- Host/IP field.
- Port field.
- Username/password fields.
- Remote path.
- Local filename.
- Streaming download to `/var/mobile/Media/iPad1FTPDownloads/`.

### Fixed during bring-up

- Added `Info.plist` to the application bundle after the first package installed only the executable and SpringBoard could not properly recognize the application.
