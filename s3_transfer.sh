#!/bin/bash
# Usage: s3_transfer.sh -s <source_bucket_name> -d <destination_bucket_name> -p <local_path>
# Do not set the destination bucket if you want to use the same bucket as the source bucket.

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Print error message
error_error() {
  echo -e "${RED}ERROR: $1${NC}" >&2
}

# Print success message
success_message() {
  echo -e "${GREEN}$1${NC}"
}

# Download from S3
down_from_s3() {
  local source_bucket="$1"
  local local_path="$2"
  aws s3 cp "s3://${source_bucket}" "${local_path}"
}

# Upload to S3
up_to_s3() {
  local destination_bucket="$1"
  local local_path="$2"
  aws s3 cp "${local_path}" "s3://${destination_bucket}"
}

# Initialize variables
SOURCE_BUCKET=""
DESTINATION_BUCKET=""
LOCAL_PATH="/tmp/s3data"

# Parse options
while getopts "s:d:p:h" opt; do
  case $opt in
    s)
      SOURCE_BUCKET="$OPTARG"
      ;;
    d)
      DESTINATION_BUCKET="$OPTARG"
      ;;
    p)
      LOCAL_PATH="$OPTARG"
      ;;
    h)
      echo "Usage: s3_transfer.sh -s <source_bucket_name> -d <destination_bucket_name> -p <local_path>"
      exit 0
      ;;
    \?)
      error_error "Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      error_error "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

# Check if source bucket is specified
if [ -z "$SOURCE_BUCKET" ]; then
  error_error "Source bucket is not specified."
  echo "Usage: s3_transfer.sh -s <source_bucket_name> -d <destination_bucket_name> -p <local_path>"
  exit 1
fi

# Set destination bucket to source bucket if not specified
if [ -z "$DESTINATION_BUCKET" ]; then
  DESTINATION_BUCKET="$SOURCE_BUCKET"
fi

# Make sure the local path exists
if [ ! -d "$LOCAL_PATH" ]; then
  error_error "Local path does not exist."
  exit 1
fi

# Download from S3
success_message "Downloading from S3 bucket: $SOURCE_BUCKET to $LOCAL_PATH"
if down_from_s3 "$SOURCE_BUCKET" "$LOCAL_PATH"; then
  success_message "Downloaded from S3 bucket: $SOURCE_BUCKET to $LOCAL_PATH"
else
  error_error "Failed to download from S3 bucket: $SOURCE_BUCKET to $LOCAL_PATH"
  exit 1
fi

# Upload to S3
success_message "Uploading to S3 bucket: $DESTINATION_BUCKET from $LOCAL_PATH"
if up_to_s3 "$DESTINATION_BUCKET" "$LOCAL_PATH"; then
  success_message "Uploaded to S3 bucket: $DESTINATION_BUCKET from $LOCAL_PATH"
else
  error_error "Failed to upload to S3 bucket: $DESTINATION_BUCKET from $LOCAL_PATH"
  exit 1
fi

# Clean up
# rm -rf "$LOCAL_PATH"
# success_message "Cleaned up local path: $LOCAL_PATH"
