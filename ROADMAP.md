# ROADMAP.md

## Product direction

Build a focused **network-transfer specialist** for iPad 1 / iOS 5.1.1.

iPad1FTPDownloader must remain small, stream-oriented and reliable on a 256 MB device. General local file management belongs to iPad1Files. PDF reading belongs to iPad1PDFReader.

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

## v1.3 — integration and stabilization

Primary objective: align the current code with `INTEGRATION.md` before adding more scope.

Required work:

- Change canonical download root to `/var/mobile/Media/iPad1Files/Downloads/`.
- Create the shared Downloads directory automatically.
- Stop creating new downloads under `/var/mobile/Media/iPad1FTPDownloads/`.
- Enforce one-file/one-physical-location behavior.
- Centralize remote-directory normalization.
- Guarantee leading `/` and trailing `/` for every remote directory path.
- Fix child navigation, parent navigation, refresh and manual path entry with the same invariant.
- Keep upload/download/rename/delete/MKD/RMD regressions working.
- Add PDFReader hand-off using `ipad1pdf://open?path=...`.
- Add optional iPad1Files hand-off using `ipad1files://show?path=...`.
- Keep the local Downloads screen lightweight; remove/avoid rich preview and general file-manager scope.

Release only after physical-device verification.

## v1.4 — transfer manager

Primary objective: make long and unreliable transfers comfortable on the iPad 1.

Planned scope:

- Pause download.
- Resume using FTP REST/transfer offsets where supported.
- Cancel transfer.
- FIFO transfer queue.
- Retry failed transfer.
- Progress percentage.
- Transfer speed.
- ETA where it can be estimated cheaply.
- Overwrite / Resume / Rename choice for local collisions.
- Transfer history kept small and metadata-only.
- Connection-loss recovery and clear failure state.
- Bounded queue size to protect memory.

All transfer implementations must remain stream-based and avoid whole-file buffering.

## v1.5 — FTP remote UX completion

Primary objective: complete the FTP-specific user experience without expanding into local file-manager territory.

Planned scope:

- Improved Saved Servers editor.
- Edit/delete server profiles.
- Remote filename/folder search.
- A→Z / Z→A sorting.
- Optional folder-first sorting.
- Human-readable remote file sizes.
- Remote date/time metadata where listing format permits it.
- Rename.
- Delete.
- MKD / RMD.
- Upload target selection.
- Small transfer-oriented multi-select only if memory/profile testing supports it.

Recursive remote search must be bounded/cancellable and should not cache an entire remote tree.

## v1.6 — sibling-app hand-off polish

Primary objective: make the three-app workflow feel seamless without copying files.

Planned scope:

- Detect completed `.pdf` files case-insensitively.
- `PDFReader ile Aç` action.
- Percent-encode the same canonical absolute path.
- Gracefully handle missing `ipad1pdf://` support.
- `Dosyalarda Göster` through `ipad1files://show?path=...` when available.
- Do not duplicate the file during any hand-off.
- Allow upload to accept a path handed in by iPad1Files when that integration is defined.

## v1.7 — saved credential hardening

Primary objective: improve credential handling without increasing memory or dependency cost materially.

Planned scope:

- iOS-5-compatible Keychain storage.
- Option not to save password.
- Anonymous FTP support/polish.
- Safe update/delete of stored credentials.
- Preserve backward compatibility with existing saved profiles where practical.

## Experimental research — SFTP

SFTP is **not** a required release milestone.

Do not integrate libssh2 directly into the main app first.

Research sequence:

1. Cross-compile a suitable libssh2 build for armv7/iOS 5.
2. Link it into a minimal standalone Theos proof-of-concept.
3. Connect/authenticate to a test server.
4. List one directory.
5. Download one file by streaming.
6. Upload one file by streaming.
7. Measure idle RAM, transfer RAM and CPU on the physical iPad 1.
8. Integrate only if the measured cost is acceptable.

If SFTP materially harms stability or memory headroom, keep it out of the product.

## Experimental research — FTPS

FTPS is separate from SFTP and requires its own TLS-aware FTP control/data transport.

Research only after the main FTP roadmap is stable:

- explicit FTP over TLS;
- implicit FTPS only if needed;
- certificate-validation behavior on iOS 5;
- contemporary server/TLS compatibility;
- memory and CPU cost;
- control/data-channel TLS handling.

If safe modern interoperability is impractical on iOS 5, document the limitation rather than shipping misleading support.

## Explicit non-goals

Do not add to iPad1FTPDownloader:

- general local copy/move;
- broad folder management;
- favorites;
- filesystem-wide local search;
- file classification;
- rich/general preview framework;
- full PDF rendering/reader features;
- ZIP manager/extractor as a general file feature;
- text editor;
- Open With registry;
- SMB client expansion;
- OCR;
- AI/ML;
- large background caches;
- whole-file RAM buffering.

## Product rule

- Network transfer problem → iPad1FTPDownloader.
- Local filesystem problem → iPad1Files.
- PDF reading/rendering problem → iPad1PDFReader.

This boundary is more important than feature count.
