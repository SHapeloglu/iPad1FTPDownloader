# TESTING.md

## Purpose

This project targets hardware and software old enough that successful compilation is not sufficient proof. Physical-device testing on an iPad 1 running iOS 5.1.1 is required for release confidence.

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

Copy package to the reachable iPad IP:

```bash
scp -o HostKeyAlgorithms=+ssh-rsa \
packages/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb \
root@192.168.1.2:/var/mobile/
```

Install on device:

```bash
dpkg -i /var/mobile/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb
su mobile -c "/usr/bin/uicache"
killall SpringBoard
```

Pass criteria:

- `dpkg` reports successful setup.
- Application bundle exists in `/Applications/`.
- App appears on SpringBoard or remains launchable after cache refresh.
- App does not immediately crash.

## Core FTP connection tests

### Valid credentials

- [ ] Enter host.
- [ ] Enter port 21 or configured FTP port.
- [ ] Enter valid username/password.
- [ ] Connect to `/`.
- [ ] Directory listing appears.

### Invalid credentials

- [ ] Use an invalid password.
- [ ] App displays a useful error.
- [ ] UI remains usable afterward.

### Unreachable host

- [ ] Use an unreachable IP/host.
- [ ] App reports connection failure.
- [ ] App does not freeze.

## Directory-path regression tests

This is a release-blocking area.

- [ ] `/` stays `/`.
- [ ] Manual `domains` becomes `/domains/`.
- [ ] Manual `/domains` becomes `/domains/`.
- [ ] Manual `/domains/` stays `/domains/`.
- [ ] Tapping `example.com` from `/domains/` results in `/domains/example.com/`.
- [ ] Tapping `public_html` results in `/domains/example.com/public_html/`.
- [ ] Tapping a nested folder does not require manually adding `/`.
- [ ] Parent navigation from `/domains/example.com/public_html/css/` produces `/domains/example.com/public_html/`.
- [ ] Repeated parent navigation eventually produces `/`.
- [ ] Refresh/listing at each level still works.

## Download tests

- [ ] Download a small text file.
- [ ] Download a medium binary/image file.
- [ ] Download a larger file appropriate for available device storage.
- [ ] Progress bytes increase.
- [ ] Percentage appears when expected size is known.
- [ ] Speed display updates.
- [ ] Final local file exists under `/var/mobile/Media/iPad1FTPDownloads/`.
- [ ] Local size matches remote size.
- [ ] Download completion does not corrupt the next directory operation.

## Pause/resume tests

- [ ] Start a sufficiently large download.
- [ ] Pause after meaningful progress.
- [ ] Confirm partial local file remains.
- [ ] Resume.
- [ ] Confirm transfer continues rather than restarting when server supports offset resume.
- [ ] Confirm final file size matches remote file size.
- [ ] Compare file hash externally where practical.
- [ ] Test against a server that rejects/does not support resume and confirm graceful behavior.

## Upload tests

- [ ] Ensure a local file exists in Downloads.
- [ ] Upload it to current remote directory.
- [ ] Progress and speed update.
- [ ] Upload reaches 100%.
- [ ] Refresh remote directory.
- [ ] Uploaded file appears.
- [ ] Remote size matches local size.

## Remote operation tests

### Rename

- [ ] Rename a file.
- [ ] Rename a folder if server permits it.
- [ ] Refresh and confirm new name.

### Delete

- [ ] Delete a remote file.
- [ ] Delete an empty remote folder.
- [ ] Attempt to delete a non-empty folder and verify useful server error.

### New folder

- [ ] Create a new folder.
- [ ] Refresh listing.
- [ ] Enter the new folder.
- [ ] Confirm path ends in `/`.

## Search and sorting

- [ ] Search substring matches files.
- [ ] Search substring matches folders.
- [ ] Clearing search restores full list.
- [ ] A→Z works.
- [ ] Z→A works.
- [ ] Sorting remains usable after directory change.

## Local Downloads manager

- [ ] Opens without crashing.
- [ ] Lists local files.
- [ ] Deletes selected local file.
- [ ] Returning to FTP screen preserves connection state where intended.

## Preview tests

- [ ] TXT.
- [ ] LOG.
- [ ] CSV.
- [ ] JPG.
- [ ] JPEG.
- [ ] PNG.
- [ ] GIF.
- [ ] HTML.
- [ ] PDF.
- [ ] Unsupported file type fails gracefully or uses a generic preview path.

## Queue tests

- [ ] Queue at least 3 downloads.
- [ ] Transfers occur in order.
- [ ] First failure does not permanently block later items unless intentionally designed that way.
- [ ] Queue count updates.
- [ ] Empty queue state is correct.

## Stress / memory tests

On the physical iPad:

- [ ] Navigate through at least 20 folder changes.
- [ ] Download multiple files sequentially.
- [ ] Upload multiple files sequentially.
- [ ] Open/close previews repeatedly.
- [ ] Watch for memory warnings, UI freezes, crashes or SpringBoard termination.

## Release gate

Do not label a development build as stable if any of these fail:

- build/package;
- app launch;
- trailing-slash navigation;
- basic download;
- basic upload;
- regression-free directory listing.
