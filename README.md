# Manage macOS via ansible

## Information

Here be dragons 🐉

This is by no means complete. It may break at any time and works for **my** personal needs.

## Preparation on a new host

If you want to install any custom CA certificates, this needs to be done manually. It is advised to do this as a first step, because `ca-certificates` will be installed by ansible and it creates a custom CA file from the macOS keychain. If you install the certificates later, you may need to reinstall `ca-certificates` manually to trigger the _postInstall_ script again.

You will want to add new hosts to the [hosts](hosts) file. Only matching hostnames will run.

## Typical steps to run

```bash
make install
make run
```
