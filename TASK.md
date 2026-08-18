# TASK.md

## Current priority

Align and stabilize **v1.3** with the iPad 1 application-family integration contract before expanding scope.

## P0 — integration-critical

- [ ] Change canonical local download root to `/var/mobile/Media/iPad1Files/Downloads/`.
- [ ] Create the canonical Downloads directory automatically when missing.
- [ ] Remove new-download use of `/var/mobile/Media/iPad1FTPDownloads/`.
- [ ] Verify a completed FTP file exists in exactly one physical location.
- [ ] Do not copy completed downloads into iPad1Files after transfer.
- [ ] Keep all remote directory paths normalized: leading `/`, trailing `/`.
- [ ] Verify tapping a child folder preserves the invariant.
- [ ] Verify parent navigation preserves the invariant.
- [ ] Verify refresh/manual path entry preserve the invariant.
- [ ] Verify root remains exactly `/`.

## P1 — FTP transfer functionality

- [ ] Build v1.3 cleanly with the current Theos toolchain.
- [ ] Confirm `.deb` installs over v1.2.
- [ ] Confirm app launches on iOS 5.1.1.
- [ ] Download into the canonical shared Downloads root.
- [ ] Upload from an existing local file without whole-file buffering.
- [ ] Pause download.
- [ ] Resume download where FTP REST/offset is supported.
- [ ] Compare resumed final file size with remote file size.
- [ ] Test server behavior when resume is unsupported.
- [ ] Transfer progress percentage.
- [ ] Transfer speed.
- [ ] FIFO queue with at least 3 sequential transfers.
- [ ] Saved servers.
- [ ] Remote rename.
- [ ] Remote delete.
- [ ] MKD / RMD.
- [ ] Remote search.
- [ ] A→Z and Z→A sorting.

## P2 — sibling-app hand-off

- [ ] On completed `.pdf`, detect extension case-insensitively.
- [ ] Add `PDFReader ile Aç` action.
- [ ] Percent-encode the absolute canonical path.
- [ ] Open `ipad1pdf://open?path=<encoded-path>` without copying the file.
- [ ] Add optional `Dosyalarda Göster` action using `ipad1files://show?path=<encoded-path>` when the scheme is available.
- [ ] If sibling app/scheme is unavailable, fail gracefully and leave the downloaded file untouched.

## P3 — local Downloads UI scope reduction

- [ ] Keep local screen limited to downloaded-file listing and transfer-oriented actions.
- [ ] Remove/avoid general local copy/move functionality.
- [ ] Remove/avoid favorites.
- [ ] Remove/avoid filesystem-wide search.
- [ ] Remove/avoid file classification.
- [ ] Remove/avoid rich preview framework.
- [ ] Remove/avoid an Open With registry.
- [ ] Prefer hand-off to iPad1Files/iPad1PDFReader instead of duplicating their features.

## P4 — regression / robustness

- [ ] Invalid credentials show useful error.
- [ ] Connection loss does not leave UI permanently disabled.
- [ ] Failed transfer closes streams and preserves app stability.
- [ ] Repeated browse/download/upload cycles do not show obvious memory growth.
- [ ] Very long queue is not allowed to grow without bounds.
- [ ] Recursive remote search is bounded/cancellable if implemented.

## P5 — security / optional protocols

- [ ] Move saved passwords to iOS-5-compatible Keychain storage.
- [ ] Evaluate libssh2 only with a minimal armv7/iOS 5 proof-of-concept first.
- [ ] Profile memory before integrating any SFTP library.
- [ ] Do not integrate heavy SMB functionality in this application.
- [ ] Evaluate FTPS separately only if it can remain lightweight and stable.

## Explicit non-goals

Do not add:

- OCR;
- AI/ML;
- whole-file RAM buffering;
- large background caches;
- general filesystem manager features;
- a full PDF reader.

## Definition of done for the integration-aligned v1.3

v1.3 is done only when:

1. build/package/install succeeds on the physical iPad 1;
2. canonical download root is `/var/mobile/Media/iPad1Files/Downloads/`;
3. no duplicate physical copy is created;
4. directory navigation requires no manual `/` correction;
5. download/upload/progress/speed/queue regressions pass;
6. PDF hand-off opens the same physical file through `ipad1pdf://`;
7. local UI remains lightweight and does not duplicate iPad1Files responsibilities;
8. `TESTING.md`, `CHANGELOG.md`, `SESSION.md` and `INTEGRATION.md` reflect actual tested behavior.
