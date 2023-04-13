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

### check-gcp-resources.sh

This script checks for the existence of a GCP resource. It only performs read operations. It currently supports these features.

```bash
Usage: ./check-gcp-resources.sh [project_id] [flags]
Flags:
  -h: Show help and usage information
  -k: Check if the service account key file exists
  -c: List Compute Engine instances
  -d: List Cloud SQL instances
  -b: List GCS buckets
  -g: List IAM groups
  -u: List IAM users
  -s: List IAM service accounts
If no flags are provided, the script will return metadata about the project.
```

Before using the script, make sure you export the following environment variables before running the script.

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

You also need to make sure that the service account has access to the resources you are trying to check.