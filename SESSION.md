# SESSION.md

## Latest hand-off

Date: 2026-08-18

## Working context

The project is developed in WSL Ubuntu with Theos for a jailbroken iPad 1 running iOS 5.1.1.

Typical local project path:

```text
~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
```

Typical iPad development IP observed recently:

```text
192.168.1.2
```

The IP can change. Verify with `ping` before deployment.

## Confirmed history

### v1.0

Initial FTP downloader built and installed successfully.

### v1.1

Added FTP directory browsing and tap-to-download. Physical-device testing confirmed directory listing and download.

### v1.2

Added upload, saved-server work, transfer progress/speed and remote file-operation infrastructure. Upload progress reached 100% on the physical iPad.

## Known path bug

On iOS 5 CFNetwork, directory-listing paths may fail unless the remote directory path ends with `/`.

Correct invariant:

```text
all remote directories start with / and end with /
```

This must be true for manual entry, current path state, child navigation, parent navigation, refresh and URL construction.

An earlier URL-only slash patch was insufficient because internal state still stored slashless paths.

## New integration decision — authoritative

iPad1FTPDownloader is now explicitly the **network-transfer specialist** in the iPad 1 app family.

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

### Canonical download root

New downloads must go directly to:

```text
/var/mobile/Media/iPad1Files/Downloads/
```

The application must create that directory if needed.

The old directory:

```text
/var/mobile/Media/iPad1FTPDownloads/
```

must not be used for new downloads.

### Single-file rule

Do not create a second copy for iPad1Files. The canonical shared file is the only physical copy.

### PDF hand-off

For completed `.pdf` files:

```text
ipad1pdf://open?path=<percent-encoded-absolute-path>
```

Open the same file; do not copy it.

Optional iPad1Files hand-off:

```text
ipad1files://show?path=<percent-encoded-absolute-path>
```

## Scope decision

Keep in iPad1FTPDownloader:

- FTP connection
- remote browse
- download/upload
- pause/resume
- progress/speed
- FIFO queue
- remote rename/delete
- MKD/RMD
- saved servers
- remote search
- sorting

Delegate to iPad1Files:

- advanced local copy/move
- general folder management
- favorites
- filesystem search
- classification
- rich/general preview
- Open With registry

Delegate PDF reading/rendering to iPad1PDFReader.

## Memory policy

Safe:

- streaming transfers
- small buffers
- queue metadata
- path hand-offs

Use caution:

- recursive remote search
- very long queues
- large previews

Do not add:

- whole-file RAM buffering
- OCR
- AI/ML
- large background caches
- heavy SFTP/SMB dependencies without physical-device profiling

## Immediate next action

Before treating v1.3 as ready, modify the actual source so it matches `INTEGRATION.md`:

1. replace the old local download root with `/var/mobile/Media/iPad1Files/Downloads/`;
2. create the shared path automatically;
3. ensure no duplicate copy is created;
4. centralize remote directory path normalization;
5. remove/avoid rich local preview/file-manager scope;
6. add PDFReader path hand-off;
7. optionally add iPad1Files `show` hand-off;
8. build and test on the physical iPad 1.

Start local work with:

```bash
cd ~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
pwd
ls
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

## Deployment reminder

WSL prompt:

```text
yeliz@DESKTOP-CSC9788:...
```

iPad prompt:

```text
apaches-iPad:~ root#
```

Run `dpkg`, iPad `uicache` and `killall SpringBoard` only after entering the iPad SSH session.

## GitHub

Repository:

```text
SHapeloglu/iPad1FTPDownloader
```

`INTEGRATION.md` is the authoritative cross-app responsibility contract. `ARCHITECTURE.md`, `TASK.md`, `README.md` and this hand-off have been aligned with it.
