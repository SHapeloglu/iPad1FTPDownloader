# TESTING.md

## Purpose

Successful compilation is not sufficient proof. Physical-device testing on an iPad 1 running iOS 5.1.1 is required for release confidence.

## Build verification

```bash
cd ~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

Pass criteria:

- No compile errors.
- No link errors.
- `.deb` created under `packages/`.
- Package version matches intended release.
- `Info.plist` is present in the staged app bundle/package.

## Install verification

```bash
scp -o HostKeyAlgorithms=+ssh-rsa \
-o PubkeyAcceptedAlgorithms=+ssh-rsa \
packages/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb \
root@192.168.1.2:/var/mobile/
```

On the iPad:

```bash
dpkg -i /var/mobile/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb
su mobile -c "/usr/bin/uicache"
killall SpringBoard
```

Pass criteria:

- package setup succeeds;
- app remains launchable;
- app does not immediately crash.

## Core FTP connection tests

### Valid credentials

- [ ] Enter host/port/username/password.
- [ ] Connect to `/`.
- [ ] Directory listing appears.

### Invalid credentials

- [ ] Invalid password reports a useful error.
- [ ] UI remains usable afterward.

### Unreachable host

- [ ] Connection failure is reported.
- [ ] App does not freeze.

## Directory-path regression tests

- [ ] `/` stays `/`.
- [ ] Manual `domains` becomes `/domains/`.
- [ ] Manual `/domains` becomes `/domains/`.
- [ ] Manual `/domains/` stays `/domains/`.
- [ ] Child navigation preserves trailing `/`.
- [ ] Nested child navigation needs no manual slash correction.
- [ ] Parent navigation returns to the correct parent.
- [ ] Repeated parent navigation eventually produces `/`.
- [ ] Refresh at each level preserves normalized state.

## FTP download tests

- [ ] Download a small text file.
- [ ] Download a medium binary/image file.
- [ ] Download a larger file appropriate for device storage.
- [ ] Progress bytes increase.
- [ ] Percentage appears when expected size is known.
- [ ] Speed display updates.
- [ ] Final file exists under `/var/mobile/Media/iPad1Files/Downloads/` or the physically verified selected descendant folder.
- [ ] No duplicate new copy appears under `/var/mobile/Media/iPad1FTPDownloads/`.
- [ ] Local size matches remote size.
- [ ] Download completion does not corrupt the next FTP directory operation.
- [ ] Large files are written progressively to disk; no whole-file RAM buffering behavior is observed.

## Pause/resume tests

- [ ] Start a sufficiently large FTP download.
- [ ] Pause after meaningful progress.
- [ ] Confirm partial local file remains.
- [ ] Resume.
- [ ] Confirm continuation rather than restart where server supports offset resume.
- [ ] Confirm final size matches remote size.
- [ ] Test a server that does not support resume and confirm graceful behavior.

## Upload tests

- [ ] Use an accessible local file from the shared Downloads area or a path handed in by iPad1Files.
- [ ] Upload to current remote FTP directory.
- [ ] Progress and speed update.
- [ ] Upload reaches 100%.
- [ ] Refresh remote directory.
- [ ] Uploaded file appears and size matches.

## Remote operation tests

### Rename

- [ ] Rename a file.
- [ ] Rename a folder if server permits it.
- [ ] Refresh and confirm new name.

### Delete

- [ ] Delete a remote file.
- [ ] Delete an empty remote folder.
- [ ] Non-empty folder failure is surfaced usefully.

### New folder

- [ ] Create a new folder.
- [ ] Refresh listing.
- [ ] Enter it.
- [ ] Confirm path ends in `/`.

## Search and sorting

- [ ] Search substring matches files in the currently loaded directory.
- [ ] Search substring matches folders in the currently loaded directory.
- [ ] Clearing search restores the full loaded listing.
- [x] A→Z works — physically verified 2026-08-29.
- [x] Z→A works — physically verified 2026-08-29.
- [ ] Folders-first works.
- [ ] Folders-first can be disabled.
- [ ] Search/sort remain usable after directory change.

## Completed-file hand-off tests

All hand-offs must use the same completed physical file; no copy is allowed.

### Video -> iPad1Player

For `.mkv`, `.mp4`, `.mov`, `.m4v`, `.avi` case-insensitively:

- [ ] Completion UI offers `iPad1Player ile Aç`.
- [ ] `ipad1player://open?path=<encoded-path>` receives the completed accessible local path.
- [ ] Cold-launch Player opens the same file.
- [ ] Warm-launch Player opens the same file.
- [ ] Unavailable Player scheme fails gracefully and leaves the file untouched.
- [ ] FTPDownloader performs no media decode/playback/subtitle handling.

### PDF -> iPad1PDFReader

- [ ] `.pdf` is detected case-insensitively.
- [ ] Completion UI offers `PDFReader ile Aç`.
- [ ] `ipad1pdf://open?path=<encoded-path>` opens the same physical file.
- [ ] Cold and warm launch work.
- [ ] Unavailable PDFReader scheme fails gracefully and leaves the file untouched.

### Other / Files

- [ ] `Dosyalarda Göster` calls `ipad1files://show?path=<encoded-path>`.
- [ ] iPad1Files shows the same physical file.
- [ ] Unavailable scheme fails gracefully.

## Download destination picker integration

- [ ] FTPDownloader requests folder selection through iPad1Files rather than implementing a second general local browser.
- [ ] Callback path is absolute and canonical.
- [ ] Callback path is accepted only under `/var/mobile/Media/iPad1Files/Downloads/`.
- [ ] Out-of-root/traversal paths are rejected.
- [ ] Fallback to canonical Downloads does not lose FTP transfer state.

## Queue / concurrency tests

- [ ] Queue at least 3 FTP downloads.
- [ ] Transfers occur in FIFO order.
- [ ] Preferred initial iPad 1 behavior keeps one active FTP transfer at a time.
- [ ] First failure does not permanently block later queued items.
- [ ] Queue metadata remains bounded.
- [ ] Queue never retains file contents.

## Scope regression tests

Confirm the application does **not** acquire sibling-owned subsystems:

- [ ] No generic HTTP/HTTPS download workflow.
- [ ] No browser URL downloader UI.
- [ ] No embedded media player/codec/subtitle engine.
- [ ] No embedded PDF renderer.
- [ ] No general local file manager or rich preview subsystem.

## Stress / memory tests

On the physical iPad:

- [ ] Navigate through at least 20 folder changes.
- [ ] Download multiple files sequentially.
- [ ] Upload multiple files sequentially.
- [ ] Exercise search/sort repeatedly.
- [ ] Exercise sibling hand-offs repeatedly after completed transfers.
- [ ] Watch for memory warnings, UI freezes, crashes or SpringBoard termination.

## Release gate

Do not label a development build stable if any required area fails:

- build/package/install;
- app launch;
- remote path normalization;
- basic FTP download;
- basic FTP upload;
- regression-free directory listing;
- changed transfer-manager behavior;
- changed sibling hand-off behavior;
- architecture scope gate.

Physical-device results are authoritative.
