# TASK.md

## Current priority

Finish **v1.3 integration/stabilization** first. Every new feature must pass the sibling-app ownership gate before implementation.

Ownership:

- FTP/network transfer -> iPad1FTPDownloader
- local filesystem/pickers -> iPad1Files
- PDF -> iPad1PDFReader
- terminal/shell -> iPad1Terminal
- VNC/remote desktop -> iPad1VNC

See `SIBLING_APP_INSTRUCTIONS.md` for delegated work.

## P0 — v1.3 integration-critical

- [x] Confirm canonical local download root is `/var/mobile/Media/iPad1Files/Downloads/` for new downloads.
- [x] Create the canonical Downloads directory automatically when missing.
- [x] Remove new-download use of `/var/mobile/Media/iPad1FTPDownloads/`.
- [x] Verify a completed FTP file exists in exactly one new physical location.
- [x] Do not copy completed downloads into iPad1Files after transfer.
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
- [ ] Add `Dosyalarda Göster` using `ipad1files://show?path=<encoded-path>`.
- [ ] Handle unavailable sibling URL schemes gracefully.
- [ ] Keep local UI limited to transfer status and hand-off; do not reintroduce local preview/file-manager controllers.

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
- [ ] Optionally support server-specific last folder if it remains simple.
- [ ] If iPad1Files scheme is unavailable, fall back to canonical Downloads without losing transfer state.

## P3 — PDF post-download preference

- [ ] Add preference modes: `Her seferinde sor`, `Otomatik PDFReader ile aç`, `Sadece indir`.
- [ ] Recommended initial default: `Her seferinde sor`.
- [ ] If auto-open is selected and `ipad1pdf://` is unavailable, leave file intact and show a useful status.
- [ ] Verify no duplicate PDF copy is created.

## P4 — v1.4 transfer manager

- [ ] Pause download.
- [ ] Resume with FTP REST/offset where supported.
- [ ] Detect unsupported resume behavior cleanly.
- [ ] Cancel transfer.
- [ ] FIFO queue.
- [ ] Limit queue length or otherwise keep metadata bounded.
- [ ] Retry failed transfer.
- [ ] Connection-loss recovery.
- [ ] ETA calculation with low CPU overhead.
- [ ] Overwrite / Resume / Rename collision choice.
- [ ] Small metadata-only transfer history.
- [ ] Test at least 3 sequential queued transfers.
- [ ] Verify no whole-file buffering.

## P5 — FTP remote UX

Competitor review shows search/sort/connection management are valid FTP-client responsibilities, while local editing/preview/media belong to sibling apps.

- [ ] Improve Saved Servers editor.
- [ ] Edit saved profile.
- [ ] Delete saved profile.
- [ ] **Source implemented, physical test pending:** remote filename/folder filtering over the already-loaded directory listing; no recursive traversal.
- [x] **Physically verified on iPad 1 (2026-08-29):** user-selectable A→Z sorting.
- [x] **Physically verified on iPad 1 (2026-08-29):** user-selectable Z→A sorting.
- [ ] **Source implemented, physical test pending:** folders-first toggle.
- [x] Human-readable remote file size already present in row UI; preserve it.
- [ ] Remote date/time metadata where server listing format permits reliable parsing.
- [ ] Upload target selection remains remote-path responsibility.
- [ ] Keep recursive remote search bounded/cancellable if ever implemented.

## P6 — app-family integration polish

- [ ] Verify folder picker round-trip with iPad1Files on physical iPad 1.
- [ ] Verify PDF hand-off with iPad1PDFReader installed.
- [ ] Verify `Dosyalarda Göster` when iPad1Files scheme is available.
- [ ] Confirm all sibling-app actions use the same physical file.
- [ ] Replace temporary FTPDownloader local upload chooser with physically verified iPad1Files `pickFile` hand-off.
- [ ] Register/handle `ipad1ftp://fileSelected?path=...` only when the iPad1Files contract is implemented and verified.
- [ ] Do not introduce an Open With registry into FTPDownloader.
- [ ] Do not add terminal, shell, VNC, PDF rendering, ZIP, text editor or general local file-manager functionality.

## P7 — credential hardening

- [ ] Move saved passwords to an iOS-5-compatible Keychain implementation.
- [ ] Add “do not save password” option.
- [ ] Polish Anonymous FTP support.
- [ ] Preserve existing saved-profile compatibility where practical.

## Experimental — SFTP / FTPS

- [ ] Build a minimal armv7/iOS 5 libssh2 proof-of-concept outside the main app.
- [ ] Measure idle RAM, transfer RAM and CPU on the physical device.
- [ ] Integrate SFTP only if profiling is acceptable.
- [ ] Evaluate FTPS separately from SFTP.
- [ ] Do not add SMB or other heavy protocols to this application.

## Explicit non-goals

Do not add advanced local copy/move, general folder management, favorites, filesystem-wide local search, classification, rich preview framework, full PDF reader functionality, ZIP manager, text editor, Open With registry, terminal/shell, VNC/remote desktop, OCR, AI/ML, whole-file RAM buffering or large background caches.

## Definition of done for v1.3

v1.3 is done only when:

1. clean build/package/install succeeds on the physical iPad 1;
2. canonical shared download root is used;
3. no duplicate physical copy is created for new transfers;
4. remote directory navigation never requires manual `/` correction;
5. download/upload and remote command regressions pass;
6. PDF hand-off opens the same physical file;
7. local UI remains lightweight and transfer-oriented;
8. sibling-owned functionality is delegated instead of duplicated;
9. folder-picker/preference work is either implemented and verified or explicitly deferred to the next tagged build;
10. `TESTING.md`, `CHANGELOG.md`, `SESSION.md`, `INTEGRATION.md` and `SIBLING_APP_INSTRUCTIONS.md` reflect actual tested behavior.
