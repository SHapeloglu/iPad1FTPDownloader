# ARCHITECTURE.md

## Overview

iPad1FTPDownloader is a lightweight legacy FTP client designed specifically for first-generation iPads running iOS 5.1.1.

The architecture deliberately favors small Objective-C classes and framework APIs available on iOS 5 over modern abstractions.

## Layers

### UI layer

Primary responsibilities:

- Connection fields
- Current remote path
- Directory table
- Search/sort controls
- Transfer progress
- Local Downloads browser
- Error/status feedback

The UI must never assume modern Auto Layout or post-iOS-5 controls.

### FTP browsing layer

`FTPBrowser`

Responsibilities:

- Build FTP directory URLs
- Apply username/password
- Read directory-listing stream
- Parse server listing into file/folder items
- Return items through a delegate

Critical invariant:

```text
remote directory path starts with / and ends with /
```

Directory normalization must happen before state is stored, not only immediately before a network request.

### Download layer

`FTPDownloader`

Responsibilities:

- Open CFFTP read stream
- Stream bytes directly into a local file
- Report progress and speed
- Support transfer offset/resume where the FTP server and CFNetwork behavior permit it
- Close streams safely on finish/failure/pause

Local target directory:

```text
/var/mobile/Media/iPad1FTPDownloads/
```

### Upload layer

`FTPUploader`

Responsibilities:

- Read local files incrementally
- Write to FTP output stream
- Report sent bytes and speed
- Avoid whole-file buffering

### Remote command layer

`FTPCommandClient`

Responsibilities:

- FTP control-channel commands not conveniently covered by CFFTP streams
- Remote file deletion (`DELE`)
- Empty-directory removal (`RMD`)
- Directory creation (`MKD`)
- Rename (`RNFR` / `RNTO`)

This code must surface server permission/reply errors rather than hiding them.

### Transfer queue

`TransferQueue`

Development responsibility:

- Store pending transfer items
- Provide FIFO semantics
- Allow a completed/failed transfer to advance to the next queued transfer

Queue persistence across app relaunch is not yet considered complete unless explicitly implemented and tested.

### Local files / preview

`LocalFilesController` and `PreviewController`

Target preview types:

- TXT / LOG / CSV
- JPG / JPEG / PNG / GIF
- HTML
- PDF

Avoid reading large binary files fully into RAM. UIWebView or streamed/native file loading is preferable for legacy compatibility.

## Saved servers

Saved server profiles may contain:

- Display name
- Host
- Port
- Username
- Password
- Initial path

Current simple persistence should be considered a usability mechanism, not a hardened secret-storage design. A future security improvement should use an iOS-5-compatible Keychain implementation.

## Secure protocol boundary

### FTP

Implemented transport family using CFNetwork/CFFTPStream and a small FTP command client.

### SFTP

Not provided by CFFTPStream. Requires a real SSH/SFTP library such as libssh2 compiled for armv7 and the target iOS SDK.

### FTPS

Requires a TLS-aware FTP transport capable of handling both control and data channels. Do not equate ordinary FTP-over-CFNetwork with full FTPS support.

## Memory constraints

iPad 1 has very limited RAM by modern standards. Architecture rules:

- Stream network transfers.
- Use small buffers.
- Release temporary objects aggressively under MRC.
- Avoid caching remote directory trees unnecessarily.
- Avoid rendering oversized images at original resolution when a scaled preview can be used.
- Test repeated transfers/navigation on the physical device for leaks and crashes.

## Build/deployment topology

Development host:

```text
Windows + WSL Ubuntu + Theos
```

Build output:

```text
.deb package
```

Deployment:

```text
WSL -> SCP -> jailbroken iPad -> dpkg -i -> SpringBoard refresh
```

Legacy OpenSSH compatibility may require a per-command `HostKeyAlgorithms=+ssh-rsa` option.

## Compatibility-first decision rule

When choosing between a cleaner modern implementation and a simpler implementation proven to work on iOS 5.1.1, prefer the latter unless there is a measurable reliability/security reason not to.
