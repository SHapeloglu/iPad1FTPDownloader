# iPad1FTPDownloader

A lightweight legacy FTP client for **iPad 1 / iOS 5.1.1 / ARMv7**, built with Objective-C, UIKit, CFNetwork and Theos.

The project exists to keep first-generation iPads useful for practical file-transfer and remote-work workflows on modern networks.

## Current status

### Confirmed on-device: v1.2

The following functionality has been exercised on an iPad 1 running iOS 5.1.1:

- FTP connection with host, port, username and password
- Remote directory listing
- Directory navigation
- Download to `/var/mobile/Media/iPad1FTPDownloads/`
- Upload
- Transfer progress and speed display
- Saved-server support
- Remote rename/delete/new-folder infrastructure

A legacy CFNetwork behavior was identified during testing: FTP directory-listing paths must end with `/`. v1.3 is intended to normalize directory paths centrally so both entering a directory and navigating to its parent preserve the trailing slash.

### In development: v1.3

v1.3 source work adds or prepares:

- Central trailing-slash normalization
- Local Downloads browser
- Search and A→Z / Z→A sorting
- TXT/CSV/LOG preview
- JPG/PNG/GIF preview
- HTML/PDF preview
- Download pause/resume using FTP transfer offsets where supported
- Transfer queue infrastructure
- Modular secure-transport integration points

**v1.3 must be treated as development code until it has been successfully built with the project Theos toolchain and tested on the physical iPad 1.**

## Target platform

- Device: iPad 1
- Architecture: armv7
- OS: iOS 5.1.1
- Packaging: `.deb`
- Build system: Theos
- Language: Objective-C
- Memory management: Manual Reference Counting (`-fno-objc-arc`)
- UI: UIKit
- FTP transport: CFNetwork / CFFTPStream

## Build

```bash
cd ~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

Expected package name for v1.3:

```text
packages/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb
```

## Install on iPad

Example device address used during development: `192.168.1.2`.

```bash
scp -o HostKeyAlgorithms=+ssh-rsa \
packages/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb \
root@192.168.1.2:/var/mobile/
```

Then connect to the iPad:

```bash
ssh -o HostKeyAlgorithms=+ssh-rsa root@192.168.1.2
```

On the iPad:

```bash
dpkg -i /var/mobile/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb
su mobile -c "/usr/bin/uicache"
killall SpringBoard
```

The old OpenSSH server on iOS 5 may require the `ssh-rsa` host-key compatibility option shown above. Do not enable obsolete algorithms globally when a per-command override is sufficient.

## Local download directory

```text
/var/mobile/Media/iPad1FTPDownloads/
```

## SFTP and FTPS

Plain FTP is the currently implemented transport.

- **SFTP:** iOS 5 CFNetwork does not provide SFTP. A practical implementation requires a library such as libssh2 compiled for armv7/iOS 5.
- **FTPS:** CFFTPStream is not a complete modern explicit/implicit FTPS client. A separate TLS-aware FTP control/data transport is required.

Do not mark SFTP or FTPS as complete until those transports are actually linked, built and verified on device.

## Project documentation

- `ARCHITECTURE.md` — technical architecture and legacy constraints
- `TASK.md` — current work queue and priorities
- `SESSION.md` — hand-off notes for the next development session
- `CLAUDE.md` — project context/instructions for Claude-style coding agents
- `AGENTS.md` — general coding-agent rules
- `TESTING.md` — build and physical-device test checklist
- `ROADMAP.md` — planned versions and priorities
- `CHANGELOG.md` — release history
- `DEVELOPMENT.md` — local development, packaging and deployment workflow

## Project principle

Reliability on iOS 5.1.1 matters more than modern API elegance. Prefer small, explicit, testable Objective-C implementations that work within the memory and framework limits of the first-generation iPad.
