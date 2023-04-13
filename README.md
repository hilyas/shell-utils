# shell-utils
A set of shell utilities and scripts to perform various local and cloud tasks

## List of scripts and utilities

### install-packages.sh

This script installs the packages listed in an array within the script. It currently only support Mac installs.

```bash
install-packages.sh -h 
Usage: install-packages.sh [flags] [package_name] [version]
Flags:
  -h: Show help and usage information
  -i: Install a package
  -c: Check installed versions of packages
If no flags are provided, the script will install all packages from the list.
```

