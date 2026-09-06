# TASK.md

## Current priority

Finish **v1.3 integration/stabilization** first. Every new feature must pass the sibling-app ownership gate before implementation.

Ownership:

- FTP transfer / remote FTP operations -> iPad1FTPDownloader
- HTTP/HTTPS downloads -> iPad1Downloader
- local filesystem/pickers -> iPad1Files
- video playback/codecs/subtitles -> iPad1Player
- PDF -> iPad1PDFReader
- terminal/shell -> iPad1Terminal
- VNC/remote desktop -> iPad1VNC

See `SIBLING_APP_INSTRUCTIONS.md` for delegated work.

## P0 — v1.3 integration-critical

- [x] Confirm canonical local download root is `/var/mobile/Media/iPad1Files/Downloads/` for new FTP downloads.
- [x] Create the canonical Downloads directory automatically when missing.
- [x] Remove new-download use of `/var/mobile/Media/iPad1FTPDownloads/`.
- [x] Verify a completed FTP file exists in exactly one new physical location.
- [x] Do not copy completed downloads after transfer merely for sibling integration.
- [x] Centralize remote directory normalization in one helper.
- [x] Enforce leading `/` and trailing `/` on remote directory navigation paths.
- [x] Verify manual path entry preserves the invariant.
- [x] Verify child-folder navigation preserves the invariant.
- [x] Verify parent navigation preserves the invariant.
- [x] Verify refresh preserves the invariant independently.
- [x] Verify root remains exactly `/` during parent navigation.
- [x] Build and install v1.3 on the physical iPad 1.

## P1 — v1.3 regression and hand-off

- [x] Download directly into `/var/mobile/Media/iPad1Files/Downloads/`.
- [ ] Upload remains stream-based and functional.
- [ ] Transfer percentage works.
- [ ] Transfer speed works.
- [ ] Saved servers still work.
- [ ] Remote rename works.
- [ ] Remote delete works.
- [ ] MKD works.
- [ ] RMD works.
- [ ] Detect completed `.pdf` extension case-insensitively.
- [ ] Add `PDFReader ile Aç` action.
- [ ] Percent-encode the canonical absolute path.
- [ ] Open `ipad1pdf://open?path=<encoded-path>` without copying the file.
- [ ] Detect completed `.mkv`, `.mp4`, `.mov`, `.m4v`, `.avi` case-insensitively.
- [ ] Add `iPad1Player ile Aç` action for completed video files.
- [ ] Open `ipad1player://open?path=<encoded-path>` only after the local file is complete and accessible.
- [ ] Do not add video decode/playback/subtitle logic to FTPDownloader.
- [ ] Add `Dosyalarda Göster` using `ipad1files://show?path=<encoded-path>`.
- [ ] Handle unavailable sibling URL schemes gracefully without touching the completed file.
- [ ] Keep local UI limited to FTP transfer status and hand-off.

## P2 — download destination preference + iPad1Files picker

- [ ] Add preference modes: `Son kullanılan klasör`, `Her indirmede sor`, `Her zaman Downloads'a indir`.
- [ ] Default to a simple/low-friction mode; final default should be decided after on-device UX testing.
- [ ] Persist only lightweight path/preference metadata.
- [ ] Add `Başka klasör seç` hand-off to iPad1Files.
- [ ] Call `ipad1files://pickFolder?root=<encoded-root>&callback=<encoded-callback>`.
- [ ] Register/handle callback `ipad1ftp://folderSelected?path=<encoded-path>`.
- [ ] Validate callback path remains under `/var/mobile/Media/iPad1Files/Downloads/`.
- [ ] Reject path traversal/out-of-root destinations.
- [ ] Remember last selected folder.
- [ ] If iPad1Files scheme is unavailable, fall back to canonical Downloads without losing FTP transfer state.

## P3 — completed-file preferences

- [ ] PDF modes: `Her seferinde sor`, `Otomatik PDFReader ile aç`, `Sadece indir`.
- [ ] Recommended PDF default: `Her seferinde sor`.
- [ ] If `ipad1pdf://` is unavailable, leave the file intact and show useful status.
- [ ] Verify no duplicate PDF copy is created.
- [ ] Consider a similarly lightweight video completion preference only after physical UX testing; do not add playback settings to FTPDownloader.

## P4 — v1.4 FTP transfer manager

- [ ] Pause FTP download.
- [ ] Resume with FTP REST/offset where supported.
- [ ] Detect unsupported resume behavior cleanly.
- [ ] Cancel transfer.
- [ ] FIFO queue.
- [ ] Keep active concurrency deliberately low on iPad 1; preferred starting point is one active FTP transfer.
- [ ] Limit queue length or otherwise keep metadata bounded.
- [ ] Retry failed FTP transfer.
- [ ] Connection-loss recovery.
- [ ] ETA calculation with low CPU overhead.
- [ ] Overwrite / Resume / Rename collision choice.
- [ ] Small metadata-only transfer history.
- [ ] Test at least 3 sequential queued transfers.
- [ ] Verify no whole-file buffering.

## P5 — FTP remote UX

- [ ] Improve Saved Servers editor.
- [ ] Edit saved profile.
- [ ] Delete saved profile.
- [ ] **Source implemented, physical test pending:** remote filename/folder filtering over the already-loaded directory listing; no recursive traversal.
- [x] **Physically verified on iPad 1 (2026-08-29):** user-selectable A→Z sorting.
- [x] **Physically verified on iPad 1 (2026-08-29):** user-selectable Z→A sorting.
- [ ] **Source implemented, physical test pending:** folders-first toggle.
- [x] Human-readable remote file size already present in row UI; preserve it.
- [ ] Remote date/time metadata where server listing format permits reliable parsing.
- [ ] Upload target selection remains remote-FTP-path responsibility.
- [ ] Keep recursive remote search bounded/cancellable if ever implemented.

## P6 — app-family integration polish

- [ ] Verify folder picker round-trip with iPad1Files on physical iPad 1.
- [ ] Verify PDF hand-off with iPad1PDFReader installed.
- [ ] Verify video hand-off with iPad1Player installed.
- [ ] Verify `Dosyalarda Göster` when iPad1Files scheme is available.
- [ ] Confirm all sibling-app actions use the same physical file.
- [ ] Replace temporary FTPDownloader local upload chooser with physically verified iPad1Files `pickFile` hand-off.
- [ ] Register/handle `ipad1ftp://fileSelected?path=...` only when the iPad1Files contract is implemented and verified.
- [ ] Do not introduce an Open With registry into FTPDownloader.

## P7 — credential hardening

- [ ] Move saved passwords to an iOS-5-compatible Keychain implementation.
- [ ] Add “do not save password” option.
- [ ] Polish Anonymous FTP support.
- [ ] Preserve existing saved-profile compatibility where practical.

## Delegated to iPad1Downloader — do not implement here

- [ ] Generic HTTP downloads.
- [ ] Generic HTTPS downloads.
- [ ] Browser/web URL download workflows.
- [ ] HTTP redirects/cookies/headers.
- [ ] HTTP/HTTPS resume semantics.
- [ ] HTTP/HTTPS queue/retry/failure handling.
- [ ] HTTP/HTTPS media download completion routing may mirror the same Player/PDFReader/Files hand-off contracts, but implementation belongs to iPad1Downloader.

## Experimental — SFTP / FTPS

- [ ] Build a minimal armv7/iOS 5 libssh2 proof-of-concept outside the main app.
- [ ] Measure idle RAM, transfer RAM and CPU on the physical device.
- [ ] Integrate SFTP only if profiling is acceptable.
- [ ] Evaluate FTPS separately from SFTP.
- [ ] Do not add SMB or other heavy protocols to this application.

## Explicit non-goals

Do not add HTTP/HTTPS downloader behavior, browser-download workflows, advanced local copy/move, general folder management, favorites, filesystem-wide local search, classification, rich preview framework, media playback/codecs/subtitles, full PDF reader functionality, ZIP manager, text editor, Open With registry, terminal/shell, VNC/remote desktop, OCR, AI/ML, whole-file RAM buffering or large background caches.

## Definition of done for v1.3

v1.3 is done only when:

1. clean build/package/install succeeds on the physical iPad 1;
2. canonical shared download root is used;
3. no duplicate physical copy is created for new FTP transfers;
4. remote directory navigation never requires manual `/` correction;
5. FTP download/upload and remote command regressions pass;
6. PDF and video completion hand-offs open the same physical file when the relevant sibling app is installed;
7. local UI remains lightweight and FTP-transfer-oriented;
8. sibling-owned functionality is delegated instead of duplicated;
9. folder-picker/preference work is either implemented and verified or explicitly deferred;
10. `TESTING.md`, `CHANGELOG.md`, `SESSION.md`, `INTEGRATION.md` and `SIBLING_APP_INSTRUCTIONS.md` reflect actual tested behavior.
