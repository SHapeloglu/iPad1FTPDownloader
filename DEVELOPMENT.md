# DEVELOPMENT.md

## Development environment

Typical setup:

- Windows host
- WSL Ubuntu
- Theos installed inside Ubuntu
- Jailbroken iPad 1 on the same LAN
- iOS 5.1.1 / armv7 target

## Project location

Current development folder pattern:

```text
~/projects/ipad1ftp/iPad1FTPDownloader_v1.3
```

Always confirm you are inside the project before running `make`:

```bash
pwd
ls
```

Expected files include:

```text
Makefile
Info.plist
control
src/
README.md
```

## Clock-skew workaround

Archives downloaded through Windows/WSL may contain timestamps in the future relative to WSL.

Before building:

```bash
find . -type f -exec touch {} +
```

Then:

```bash
make clean
make package FINALPACKAGE=1
```

A warning such as `Clock skew detected` may not always stop a build, but fixing timestamps removes ambiguity.

## Expected package

For v1.3:

```text
packages/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb
```

Verify:

```bash
ls -lh packages/
```

## Network check

The iPad DHCP address may change. Check reachability before SCP:

```bash
ping -c 4 192.168.1.2
```

Use the actual current address if different.

## Copy to iPad

Old iOS OpenSSH may require RSA host-key compatibility:

```bash
scp -o HostKeyAlgorithms=+ssh-rsa \
packages/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb \
root@192.168.1.2:/var/mobile/
```

A post-quantum warning from modern OpenSSH is expected when connecting to this legacy SSH server. The compatibility setting should remain scoped to this device/command.

## Enter the iPad shell

```bash
ssh -o HostKeyAlgorithms=+ssh-rsa root@192.168.1.2
```

The prompt changes from something like:

```text
yeliz@DESKTOP-CSC9788:...
```

to:

```text
apaches-iPad:~ root#
```

Only after that change should iPad package commands be used.

## Install

On the iPad:

```bash
dpkg -i /var/mobile/com.olap.ipad1ftpdownloader_1.3.0_iphoneos-arm.deb
su mobile -c "/usr/bin/uicache"
killall SpringBoard
```

Some legacy `uicache` versions print non-fatal process/cache messages. Verify the actual app bundle and launch behavior instead of treating every message as an installation failure.

## Bundle diagnostics

```bash
ls -la /Applications/iPad1FTPDownloader.app
```

The bundle must contain at minimum:

```text
Info.plist
iPad1FTPDownloader
```

If the icon is missing, refresh cache/SpringBoard. If the application opens then immediately exits, run the executable from the iPad shell to capture a runtime error:

```bash
/Applications/iPad1FTPDownloader.app/iPad1FTPDownloader
```

## Version discipline

Before a release, keep these aligned:

- `control` package version
- `Info.plist` bundle versions
- README examples
- package filename in documentation
- CHANGELOG section

## Git workflow

Recommended:

```bash
git status
git add .
git commit -m "feat: ..."
git push origin main
```

Before pushing, inspect for accidental credentials:

```bash
git diff --cached
```

Do not commit FTP passwords, private server credentials, SSH private keys, or sensitive production configuration.

## Debugging principle

For this project, reproduce on the physical iPad whenever behavior could differ due to:

- iOS 5 CFNetwork;
- legacy UIKit;
- filesystem permissions;
- SpringBoard cache;
- armv7 linking;
- old OpenSSH;
- low-memory pressure.
