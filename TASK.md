# TASK.md

## Current priority

Finish **v1.3 integration/stabilization** first. Do not add new local file-manager scope before the shared-path and remote-path invariants are proven on the physical iPad 1.

## P0 — v1.3 integration-critical

- [ ] Change canonical local download root to `/var/mobile/Media/iPad1Files/Downloads/`.
- [ ] Create the canonical Downloads directory automatically when missing.
- [ ] Remove new-download use of `/var/mobile/Media/iPad1FTPDownloads/`.
- [ ] Verify a completed FTP file exists in exactly one physical location.
- [ ] Do not copy completed downloads into iPad1Files after transfer.
- [ ] Centralize remote directory normalization in one helper.
- [ ] Enforce leading `/` and trailing `/` on every remote directory path.
- [ ] Verify manual path entry preserves the invariant.
- [ ] Verify child-folder navigation preserves the invariant.
- [ ] Verify parent navigation preserves the invariant.
- [ ] Verify refresh preserves the invariant.
- [ ] Verify root remains exactly `/`.
- [ ] Build and install v1.3 on the physical iPad 1.

## P1 — v1.3 regression and hand-off

- [ ] Download directly into `/var/mobile/Media/iPad1Files/Downloads/`.
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
- [ ] Add optional `Dosyalarda Göster` using `ipad1files://show?path=<encoded-path>`.
- [ ] Handle unavailable sibling URL schemes gracefully.
- [ ] Keep local Downloads view limited to listing/opening transfer results.

## P2 — v1.4 transfer manager

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

## P3 — v1.5 FTP remote UX

- [ ] Improve Saved Servers editor.
- [ ] Edit saved profile.
- [ ] Delete saved profile.
- [ ] Remote filename/folder search.
- [ ] A→Z sorting.
- [ ] Z→A sorting.
- [ ] Optional folder-first sorting.
- [ ] Human-readable remote file size.
- [ ] Remote date/time metadata where server listing permits it.
- [ ] Upload target selection.
- [ ] Keep recursive remote search bounded/cancellable if implemented.

## P4 — v1.6 app-family integration polish

- [ ] Verify PDF hand-off with iPad1PDFReader installed.
- [ ] Verify `Dosyalarda Göster` when iPad1Files scheme is available.
- [ ] Confirm both sibling-app actions use the same physical file.
- [ ] Define upload-from-iPad1Files path hand-off if needed.
- [ ] Do not introduce an Open With registry into FTPDownloader.

## P5 — v1.7 credential hardening

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

Do not add:

- advanced local copy/move;
- general folder management;
- favorites;
- filesystem-wide local search;
- classification;
- rich preview framework;
- full PDF reader functionality;
- ZIP manager;
- text editor;
- Open With registry;
- OCR;
- AI/ML;
- whole-file RAM buffering;
- large background caches.

## Definition of done for v1.3

v1.3 is done only when:

1. clean build/package/install succeeds on the physical iPad 1;
2. canonical download root is `/var/mobile/Media/iPad1Files/Downloads/`;
3. no duplicate physical copy is created;
4. remote directory navigation never requires manual `/` correction;
5. download/upload and remote command regressions pass;
6. PDF hand-off opens the same physical file;
7. local UI remains lightweight and transfer-oriented;
8. `TESTING.md`, `CHANGELOG.md`, `SESSION.md` and `INTEGRATION.md` reflect actual tested behavior.
