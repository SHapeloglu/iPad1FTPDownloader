# SESSION.md

## Latest hand-off

Date: 2026-08-18

## Working context

The project is being developed in WSL Ubuntu with Theos for a jailbroken iPad 1 running iOS 5.1.1.

Typical local paths used recently:

```text
~/projects/ipad1ftp/iPad1FTPDownloader_v1.2
~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
```

Typical iPad development IP observed recently:

```text
192.168.1.2
```

The iPad address can change. Verify with ping before deployment.

## Confirmed history

### v1.0

Initial lightweight FTP downloader built and installed successfully.

A packaging problem was found because `Info.plist` was initially absent from the app bundle. After adding it as a resource, SpringBoard could recognize the application.

### v1.1

Added FTP directory browsing and tap-to-download.

Physical-device testing confirmed:

- FTP directory listing works.
- Folders are visible.
- Files can be tapped and downloaded.
- Download completion path is shown.

### v1.2

Added broader FTP-client features, including:

- upload;
- saved-server work;
- transfer progress/speed;
- remote file-operation infrastructure.

Physical-device screenshot/testing confirmed upload progress reached 100% and displayed transfer speed.

## Current known bug / discovery

On the old iOS 5 CFNetwork FTP implementation, directory listing fails for some paths unless the path ends with `/`.

Observed behavior:

```text
/domains/example.com/public_html/css
```

can fail, while:

```text
/domains/example.com/public_html/css/
```

works.

An initial patch that only appended `/` while constructing the FTP URL was insufficient because the application navigation state still stored paths without the slash. Parent navigation had the same issue.

The correct fix is to keep a single path invariant throughout application state:

```text
all remote directories start with / and end with /
```

This includes:

- manually entered directory paths;
- current path;
- tapping a child directory;
- refreshing;
- parent navigation;
- FTP listing URL construction.

## v1.3 intent

v1.3 was prepared to combine the path fix with:

- local Downloads browser;
- remote search;
- A→Z/Z→A sort;
- basic file preview;
- pause/resume infrastructure;
- transfer queue infrastructure;
- secure-transport integration boundary.

SFTP and FTPS are **not verified/complete transports**. Do not report them as supported until real libraries/transport code are linked and tested.

## Next session start

Start with:

```bash
cd ~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
pwd
ls
find . -type f -exec touch {} +
make clean
make package FINALPACKAGE=1
```

If build succeeds, inspect:

```bash
ls -lh packages/
```

Then deploy to the currently reachable iPad IP.

Example:

```bash
scp -o HostKeyAlgorithms=+ssh-rsa \
packages/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb \
root@192.168.1.2:/var/mobile/
```

Connect:

```bash
ssh -o HostKeyAlgorithms=+ssh-rsa root@192.168.1.2
```

Install on iPad:

```bash
dpkg -i /var/mobile/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb
su mobile -c "/usr/bin/uicache"
killall SpringBoard
```

## Important terminal reminder

When the prompt looks like:

```text
yeliz@DESKTOP-CSC9788:...
```

commands are running in Ubuntu/WSL.

When it looks like:

```text
apaches-iPad:~ root#
```

commands are running on the iPad.

Run `dpkg`, iPad `uicache`, and `killall SpringBoard` only after entering the iPad SSH session.

## GitHub

Repository:

```text
SHapeloglu/iPad1FTPDownloader
```

The documentation set was initialized on `main` so a new chat or coding agent can reconstruct the project without relying on conversation history.
