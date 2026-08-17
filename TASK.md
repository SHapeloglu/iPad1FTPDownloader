# TASK.md

## Current priority

Stabilize **v1.3** on the physical iPad 1 before adding more protocol scope.

## P0 — must verify next

- [ ] Build v1.3 cleanly with the current Theos toolchain.
- [ ] Confirm `.deb` installs over v1.2.
- [ ] Confirm app launches on iOS 5.1.1.
- [ ] Verify remote directory paths always end with `/`.
- [ ] Verify tapping a folder enters it without manual path editing.
- [ ] Verify `Üst`/parent navigation also preserves the trailing `/`.
- [ ] Verify root path remains exactly `/`.
- [ ] Verify download still works after path-normalization changes.
- [ ] Verify upload still works after v1.3 changes.

## P1 — v1.3 feature verification

- [ ] Search remote list by filename/folder name.
- [ ] A→Z sorting.
- [ ] Z→A sorting.
- [ ] Open local Downloads browser.
- [ ] Delete local file from Downloads browser.
- [ ] Preview TXT/LOG/CSV.
- [ ] Preview JPG/JPEG/PNG/GIF.
- [ ] Preview HTML.
- [ ] Preview PDF.
- [ ] Pause a download.
- [ ] Resume the same download.
- [ ] Compare resumed final file size with remote file size.
- [ ] Test server behavior when REST/resume is unsupported.
- [ ] Test transfer queue with at least 3 sequential transfers.

## P2 — regression checks

- [ ] Saved server profile still loads correctly.
- [ ] Upload progress percentage and speed still update.
- [ ] Download progress percentage and speed still update.
- [ ] Remote rename still works.
- [ ] Remote delete still works.
- [ ] New remote folder creation still works.
- [ ] Empty folder deletion returns a useful error when server rejects it.
- [ ] Invalid credentials display a useful error.
- [ ] Connection loss does not leave the UI permanently disabled.

## P3 — security / protocol work

- [ ] Evaluate libssh2 version/toolchain suitable for armv7 + iOS 5.
- [ ] Build a minimal libssh2 test binary/app before integrating SFTP UI.
- [ ] Implement real SFTP directory list/download/upload only after library proof-of-concept succeeds.
- [ ] Evaluate explicit FTPS requirements and TLS compatibility on iOS 5.
- [ ] Decide whether FTPS is practical enough to justify maintenance cost.
- [ ] Move saved passwords to an iOS-5-compatible Keychain implementation.

## P4 — polish

- [ ] Human-readable local file sizes in Downloads browser.
- [ ] Sort folders before files as an option.
- [ ] Persistent transfer queue.
- [ ] Cancel transfer button.
- [ ] Better transfer history.
- [ ] More useful empty/error states.
- [ ] Application icon suitable for legacy SpringBoard.
- [ ] Release notes for v1.3.

## Definition of done for v1.3

v1.3 is not done merely because it compiles. It is done when:

1. clean build succeeds;
2. package installs on the physical iPad 1;
3. folder navigation works without manually adding `/`;
4. download/upload regressions pass;
5. local files, search/sort and previews are tested;
6. pause/resume behavior is validated against at least one real FTP server;
7. `TESTING.md`, `CHANGELOG.md` and `SESSION.md` are updated with actual results.
