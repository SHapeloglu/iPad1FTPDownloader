# SECURITY.md

## Scope

This is a legacy-client project targeting iOS 5.1.1. The operating system and its TLS/SSH ecosystem are obsolete by modern security standards. Security claims must therefore be conservative and explicit.

## Credentials

Never commit:

- FTP passwords
- production usernames tied to sensitive systems
- SSH private keys
- API tokens
- hosting-panel credentials
- private server configuration

Use placeholders in documentation and screenshots intended for public repositories.

## Plain FTP

Plain FTP does not encrypt credentials or file contents in transit. Use it only on networks/servers where that risk is understood and acceptable.

## SFTP

SFTP is not implemented merely by having UI options or abstraction classes. It requires a real SSH/SFTP transport such as libssh2 compiled for the iOS 5/armv7 target and verified on the physical device.

## FTPS

FTPS requires a real TLS-capable FTP implementation. Legacy iOS 5 TLS capabilities may be incompatible with modern server policies. Do not weaken a production server's TLS configuration solely to accommodate this client without understanding the security impact.

## Saved passwords

If saved-server profiles persist passwords in simple preferences, treat that as convenience rather than secure secret storage. A future hardening step should move secrets into an iOS-5-compatible Keychain implementation.

## Legacy SSH used for deployment

Modern OpenSSH may require this compatibility override to communicate with the jailbroken iPad's old SSH daemon:

```bash
-o HostKeyAlgorithms=+ssh-rsa
```

Keep the override scoped to the single command or host-specific SSH configuration. Do not globally re-enable obsolete algorithms for unrelated hosts.

## Vulnerability reports

When reporting a security issue, include:

- affected version;
- iOS version/device;
- protocol involved;
- reproducible steps;
- whether the issue exposes credentials, file contents, or arbitrary filesystem access;
- whether the behavior is caused by the application or the legacy platform itself.

## Release rule

Do not describe a protocol or credential-storage feature as secure until its actual implementation and on-device behavior have been reviewed and tested.
