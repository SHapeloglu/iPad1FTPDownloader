# AGENTS.md

## Purpose

This file gives coding agents a compact operational contract for this repository.

## Target

- iPad 1
- iOS 5.1.1
- armv7
- Theos
- Objective-C
- UIKit / Foundation / CFNetwork
- Manual Reference Counting

## Rules

1. Preserve iOS 5 compatibility.
2. Do not introduce Swift.
3. Do not silently require ARC.
4. Do not use APIs newer than iOS 5 without compatibility guards.
5. Keep networking asynchronous.
6. Avoid large in-memory buffers.
7. Keep the `.deb` packaging flow intact.
8. Never commit credentials.
9. Treat physical iPad behavior as the source of truth.
10. Update docs when behavior or architecture changes.
11. Before proposing or implementing any feature, perform the sibling-app ownership check below.

## Mandatory sibling-app ownership check

- FTP transfer / remote FTP operation -> **iPad1FTPDownloader**
- HTTP/HTTPS download -> **iPad1Downloader**
- local filesystem / picker / file-management -> **iPad1Files**
- video playback / codecs / subtitles -> **iPad1Player**
- PDF rendering / reading -> **iPad1PDFReader**
- terminal / shell -> **iPad1Terminal**
- VNC / remote desktop -> **iPad1VNC**

Transport determines downloader ownership. A media file downloaded over FTP is still an iPad1FTPDownloader transfer; after successful completion, hand only the accessible local path to iPad1Player.

Do not add HTTP/HTTPS downloader behavior to this repository. Do not add media playback behavior here. Prefer shared physical paths and lightweight URL-scheme hand-offs.

## Directory-path invariant

Every remote FTP directory path must:

- start with `/`
- end with `/`
- represent root as exactly `/`

This invariant must hold in UI state, navigation state and FTP URL construction.

## Transfer principles

- Stream FTP downloads directly to disk.
- Stream FTP uploads directly from disk.
- Keep transfer buffers small.
- Keep active concurrency deliberately low on iPad 1.
- Expose user-visible errors.
- If implementing resume, verify FTP server support and local file offset behavior.
- Do not call a transfer complete until the stream ended cleanly.
- Completed video may be handed to `ipad1player://open?path=...`; do not decode/play it here.

## Secure protocols

SFTP and FTPS are not considered implemented until actual working transports are linked and tested on iPad 1.

## Required validation after source changes

```bash
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

Then install on the physical iPad and run the relevant cases from `TESTING.md`.

## Documentation ownership

- `README.md`: user/project overview
- `ARCHITECTURE.md`: structure and technical decisions
- `TASK.md`: active backlog
- `SESSION.md`: latest hand-off state
- `TESTING.md`: verification plan
- `ROADMAP.md`: future versions
- `CHANGELOG.md`: released/development changes
- `DEVELOPMENT.md`: build/install workflow
- `CLAUDE.md`: detailed agent context
