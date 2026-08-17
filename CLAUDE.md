# CLAUDE.md

## Project identity

This repository is **iPad1FTPDownloader**, a legacy FTP file client for **iPad 1 / iOS 5.1.1 / armv7**.

The primary goal is not modern iOS compatibility. The primary goal is to produce a stable, lightweight application that can still build with Theos and run on a first-generation iPad with very limited RAM.

## Non-negotiable constraints

- Target iOS 5.1.1.
- Target armv7.
- Use Objective-C and UIKit APIs available to iOS 5.
- Manual memory management is enabled; do not introduce ARC-only assumptions.
- Avoid APIs introduced after iOS 5 unless guarded and proven safe.
- Avoid Swift.
- Avoid large third-party frameworks unless there is no reasonable alternative.
- Preserve Theos `.deb` packaging.
- Do not assume App Store deployment.
- Physical-device testing matters more than simulator-only success.

## Build environment

Typical project location:

```text
~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
```

Typical build:

```bash
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

`find ... touch` is used to avoid WSL/host clock-skew warnings after archive extraction.

## Legacy SSH deployment

The iPad's old SSH server may only offer legacy RSA host keys. Use a per-command compatibility option instead of weakening the host globally:

```bash
scp -o HostKeyAlgorithms=+ssh-rsa <package.deb> root@192.168.1.2:/var/mobile/
ssh -o HostKeyAlgorithms=+ssh-rsa root@192.168.1.2
```

## Known FTP behavior

On iOS 5 CFNetwork, FTP directory-listing URLs should be normalized so directory paths end in `/`.

Correct examples:

```text
/
/domains/
/domains/example.com/
/domains/example.com/public_html/
```

Incorrect directory state must not be allowed to propagate internally:

```text
/domains/example.com/public_html
```

Path normalization should happen centrally, not only when creating a URL. Entering a directory, manually entering a directory path, refreshing, and navigating to the parent must all preserve the same invariant.

## Current release status

### v1.2

Known to have been built and installed on the physical iPad. FTP listing, download and upload were observed working. Transfer percentage/speed UI was observed working.

### v1.3

Development branch/source state. Intended to add local file browsing, search/sort, preview, pause/resume and queue infrastructure. Treat these as unverified until the exact source has built successfully and passed device testing.

## SFTP / FTPS rule

Never claim SFTP or FTPS support merely because stubs, UI fields, enums or integration points exist.

- SFTP requires an actual SSH/SFTP implementation, most likely libssh2 compiled for the target.
- FTPS requires a real TLS-capable FTP control/data implementation.

A successful plain FTP build is more important than speculative secure-protocol code that breaks iOS 5 compilation.

## Coding style

Prefer:

- Small Objective-C classes with single responsibilities.
- Clear delegates over complex dependency patterns.
- Foundation collections and UIKit controls available in iOS 5.
- Defensive nil/error handling.
- 8–16 KB transfer buffers rather than excessive buffering.
- Explicit release/dealloc ownership rules.

Avoid:

- Modern-only Objective-C conveniences without compatibility checks.
- Large memory copies of remote files.
- Loading entire large files into RAM for preview.
- Blocking network operations on the main thread.
- Silent error swallowing where the user needs actionable feedback.

## Security

- Never commit real FTP passwords or production secrets.
- Example IPs and usernames should be placeholders unless intentionally public.
- Saved passwords are currently a usability feature, not a strong secret-storage design. If improving credential storage, use an iOS-5-compatible Keychain solution.

## Before making a release

1. Build from a clean tree.
2. Confirm `.deb` version matches `control` and `Info.plist`.
3. Install over the previous version with `dpkg -i`.
4. Refresh SpringBoard.
5. Test listing from `/` and nested folders.
6. Test parent navigation and trailing slash handling.
7. Test download and verify file size.
8. Test upload and verify server-side file size.
9. Test rename/delete/new folder if changed.
10. Test memory stability with several navigation/transfer cycles.
11. Update `CHANGELOG.md`, `SESSION.md` and `TASK.md`.
