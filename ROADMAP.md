# ROADMAP.md

## Product direction

Build a practical **legacy file client for iPad 1 / iOS 5.1.1**, prioritizing reliability and low memory usage over feature count.

## v1.3 — stabilization

Primary objective: make the current FTP client dependable.

Planned / under verification:

- Central remote-path normalization
- Reliable parent navigation
- Local Downloads browser
- Search
- Sort
- Basic preview
- Pause/resume
- Transfer queue
- Regression testing for upload/download/remote file operations

Release only after physical-device verification.

## v1.4 — transfer manager and UX

Potential scope:

- Persistent transfer history
- Cancel transfer
- Better queue management
- Retry failed transfer
- Clearer ETA/speed presentation
- User-selectable overwrite/resume behavior
- Better human-readable local file metadata
- Optional folder-first sorting
- Improved saved-server editor
- Keychain-backed credential storage

## v1.5 — SFTP proof of concept

Do not begin full SFTP UI work until a minimal libssh2 proof of concept succeeds on the target.

Milestones:

1. Cross-compile libssh2 for armv7/iOS 5 toolchain.
2. Link into a minimal Theos application.
3. Connect/authenticate against a test SSH server.
4. List a directory.
5. Download a file.
6. Upload a file.
7. Only then integrate with the main browser/transfer UI.

## v1.6 — secure-protocol integration

If v1.5 succeeds:

- Saved protocol per server profile
- SFTP browse/download/upload
- SFTP rename/delete/mkdir
- Password authentication
- Evaluate SSH public-key authentication compatible with legacy target

## FTPS research track

FTPS is separate from SFTP and should not share an implementation merely because both are secure transports.

Research:

- Explicit FTP over TLS
- Implicit FTPS if needed
- TLS compatibility with contemporary servers
- Certificate validation behavior on iOS 5
- Separate control/data channel handling

If contemporary TLS requirements make a safe/maintainable iOS 5 implementation impractical, document that limitation instead of shipping misleading support.

## Long-term optional features

- ZIP extraction
- More local file operations
- Lightweight text editor
- Image scaling/rotation preview
- Integration with the separate legacy PDF-reader work
- Simple HTTP/HTTPS downloader mode
- WebDAV if a lightweight compatible implementation proves practical

## Non-goals

Unless hardware testing proves otherwise, avoid turning the project into a heavy modern file manager with large cloud SDKs or background services. The product advantage is that it remains useful on a 2010-era iPad.
