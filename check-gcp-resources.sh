#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Show help message
function show_help() {
    echo -e "Usage: $0 [project_id] [flags]"
    echo "Flags:"
    echo "  -h: Show help and usage information"
    echo "  -p: Show project metadata"
    echo "  -k: Check if the service account key file exists"
    echo "  -c: List Compute Engine instances"
    echo "  -d: List Cloud SQL instances"
    echo "  -b: List GCS buckets"
    echo "  -g: List IAM groups"
    echo "  -u: List IAM users"
    echo "  -s: List IAM service accounts"
}

# Load the GOOGLE_APPLICATION_CREDENTIALS environment variable
export GOOGLE_APPLICATION_CREDENTIALS="$GOOGLE_APPLICATION_CREDENTIALS"

function check_service_account_key() {
    if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
        echo -e "${RED}The GOOGLE_APPLICATION_CREDENTIALS environment variable is not set.${NC}"
        exit 1
    elif [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
        echo -e "${GREEN}The file specified by the GOOGLE_APPLICATION_CREDENTIALS environment variable is at: $GOOGLE_APPLICATION_CREDENTIALS${NC}"
        exit 1
    fi
}

# Function to list Compute Engine instances
function list_compute_instances() {
    local project_id="$1"
    echo -e "${GREEN}Listing Compute Engine instances in project $project_id:${NC}"
    gcloud compute instances list --project "$project_id"
}

# Function to list Cloud SQL instances
function list_cloudsql_instances() {
    local project_id="$1"
    echo -e "${GREEN}Listing Cloud SQL instances in project $project_id:${NC}"
    gcloud sql instances list --project "$project_id"
}

# Function to list GCS buckets
function list_gcs_buckets() {
    local project_id="$1"
    echo -e "${GREEN}Listing GCS buckets in project $project_id:${NC}"
    gsutil ls -p "$project_id"
}

# Function to list IAM groups
function list_iam_groups() {
    local project_id="$1"
    echo -e "${GREEN}Listing IAM groups in project $project_id:${NC}"
    gcloud projects get-iam-policy "$project_id" --flatten="bindings[].members" --format="table(bindings.members:label=GROUP)" --filter="bindings.members:group"
}

# Function to list IAM users
function list_iam_users() {
    local project_id="$1"
    echo -e "${GREEN}Listing IAM users in project $project_id:${NC}"
    gcloud projects get-iam-policy "$project_id" --flatten="bindings[].members" --format="table(bindings.members:label=USER)" --filter="bindings.members:user"
}

# Function to list IAM service accounts
function list_iam_service_accounts() {
    local project_id="$1"
    echo -e "${GREEN}Listing IAM service accounts in project $project_id:${NC}"
    gcloud iam service-accounts list --project "$project_id"
}

function show_project_metadata() {
    if [ -z "$project_id" ]; then
        echo -e "${RED}No project ID provided. Please provide a project ID using the -p flag.${NC}"
        show_help
        exit 1
    else
        gcloud projects describe "$project_id"
    fi
}

function main() {
    # Check if the project_id is provided
    if [ $# -lt 2 ]; then
        echo -e "${RED}Please use a flag to check a resource.${NC}"
        show_help
        exit 1
    fi

    project_id="$1"
    shift

    # Process the flags
    for flag in "$@"; do
        case "$flag" in
        -h)
            show_help
            ;;
        -p)
            show_project_metadata
            ;;
        -k)
            check_service_account_key
            ;;
        -c)
            list_compute_instances "$project_id"
            ;;
        -d)
            list_cloudsql_instances "$project_id"
            ;;
        -b)
            list_gcs_buckets "$project_id"
            ;;
        -g)
            list_iam_groups "$project_id"
            ;;
        -u)
            list_iam_users "$project_id"
            ;;
        -a)
            list_iam_service_accounts "$project_id"
            ;;
        *)
            echo -e "${RED}Invalid flag: ${flag}${NC}"
            exit 1
            ;;
        esac
    done
}

main "$@"
