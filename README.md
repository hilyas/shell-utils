# shell-utils

A set of shell utilities and scripts to perform various local and cloud tasks. They are mostly used for my personal needs, feel free to use them as you see fit (at your own risk). I will try to keep them up to date as I add more scripts and utilities.

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
Usage: check-gpc-resources.sh [project_id] [flags]
Example: check-gpc-resources.sh my-project-id -pcdbu
Flags:
  -h: Show help and usage information
  -p: Show project metadata
  -k: Check if the service account key file exists
  -c: List Compute Engine instances
  -d: List Cloud SQL instances
  -b: List GCS buckets
  -g: List IAM groups
  -u: List IAM users
  -s: List IAM service accounts
  -a: List all resources
```

Before using the script, make sure you export the following environment variables before running the script.

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

You also need to make sure that the service account has access to the resources you are trying to check.

### s3_transfer.sh

TBD

### check-aws-resources.sh

The script checks for the existance of an AWS resource. It only performs read operations. It currently supports these features:

```bash
Usage: check-aws-resources.sh [flags] [--profile PROFILE_NAME] [--region REGION]
Example: ./check-aws-resources.sh -esri --profile sandbox-admin --region us-west-2
Options:
  --profile PROFILE_NAME: Specify the AWS profile to use
  --region REGION: Specify the AWS region to use
Flags:
  -h: Show help and usage information
  -e: List EC2 instances
  -s: List S3 buckets
  -r: List RDS instances
  -i: List IAM users
  -a: List all resources
```

### ping-db.sh  

Currently support PostgreSQL only.

```bash
./ping-db.sh '"host=<hostname> port=5432 dbname=postgres user=postgres password=SecurePassword123"'
```
