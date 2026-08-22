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

## Directory-path invariant

Every remote directory path must be normalized to:

- start with `/`
- end with `/`

Root is exactly `/`.

Examples:

```text
/
/domains/
/domains/example.com/public_html/
```

This invariant must hold in the UI state, navigation state and FTP URL construction.

## Transfer principles

- Stream downloads directly to disk.
- Stream uploads directly from disk.
- Keep transfer buffers small.
- Expose user-visible errors.
- If implementing resume, verify server support and local file offset behavior.
- Do not call a transfer complete until the stream ended cleanly.

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
