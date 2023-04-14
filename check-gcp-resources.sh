#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Show help message
function show_help() {
    echo -e "Usage: check-gpc-resources.sh [project_id] [flags]"
    echo -e "Example: check-gpc-resources.sh my-project-id -pcdbu"
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
    echo "  -a: List all resources"
}

# Load the GOOGLE_APPLICATION_CREDENTIALS environment variable
export GOOGLE_APPLICATION_CREDENTIALS="$GOOGLE_APPLICATION_CREDENTIALS"

function check_service_account_key() {
    if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
        echo -e "${RED}The GOOGLE_APPLICATION_CREDENTIALS environment variable is not set.${NC}"
        exit 1
    elif [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
        echo -e "${GREEN}The file specified by \
                    the GOOGLE_APPLICATION_CREDENTIALS \
                    environment variable is at: $GOOGLE_APPLICATION_CREDENTIALS${NC}"
        exit 1
    fi
}

# Function to check if the output is empty
function check_gcloud_output() {
    output="$1"
    resource_type="$2"

    if [[ -z "$output" ]]; then
        echo -e "${YELLOW}There are no ${resource_type}.${NC}"
    else
        echo "$output"
    fi
}

# Function to list Compute Engine instances
function list_compute_instances() {
    local project_id="$1"
    echo -e "${GREEN}Listing Compute Engine instances in project $project_id:${NC}"
    instances=$(gcloud compute instances list \
                    --project "$project_id")
    check_gcloud_output "$instances" "Compute instances"
}

# Function to list Cloud SQL instances
function list_cloudsql_instances() {
    local project_id="$1"
    echo -e "${GREEN}Listing Cloud SQL instances in project $project_id:${NC}"
    cloudsql_instances=$(gcloud sql instances list \
                            --project "$project_id")
    check_gcloud_output "$cloudsql_instances" "Cloud SQL instances"
}

# Function to list GCS buckets
function list_gcs_buckets() {
    local project_id="$1"
    echo -e "${GREEN}Listing GCS buckets in project $project_id:${NC}"
    buckets=$(gsutil ls -p "$project_id")
    check_gcloud_output "$buckets" "GCS buckets"
}

# Function to list IAM groups
function list_iam_groups() {
    local project_id="$1"
    echo -e "${GREEN}Listing IAM groups in project $project_id:${NC}"
    groups=$(gcloud projects get-iam-policy "$project_id" \
                --flatten="bindings[].members" \
                --format="table(bindings.members:label=GROUP)" \
                --filter="bindings.members:group")
    check_gcloud_output "$groups" "IAM groups"
}

# Function to list IAM users
function list_iam_users() {
    local project_id="$1"
    echo -e "${GREEN}Listing IAM users in project $project_id:${NC}"
    users=$(gcloud projects get-iam-policy "$project_id" \
                --flatten="bindings[].members" \
                --format="table(bindings.members:label=USER)" \
                --filter="bindings.members:user")
    check_gcloud_output "$users" "IAM users"
}

# Function to list IAM service accounts
function list_iam_service_accounts() {
    local project_id="$1"
    echo -e "${GREEN}Listing IAM service accounts in project $project_id:${NC}"
    service_accounts=$(gcloud iam service-accounts list \
                            --project "$project_id")
    check_gcloud_output "$service_accounts" "IAM service accounts"
}

function list_all_resources() {
    local project_id="$1"
    list_compute_instances "$project_id"; echo ""
    list_cloudsql_instances "$project_id"; echo ""
    list_gcs_buckets "$project_id"; echo ""
    list_iam_groups "$project_id"; echo ""
    list_iam_users "$project_id"; echo ""
    list_iam_service_accounts "$project_id"; echo ""
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

    while getopts ":hpkcdbgua" opt; do
        case $opt in
            h) show_help ;;
            p) show_project_metadata ;;
            k) check_service_account_key ;;
            c) list_compute_instances "$project_id" ;;
            d) list_cloudsql_instances "$project_id" ;;
            b) list_gcs_buckets "$project_id" ;;
            g) list_iam_groups "$project_id" ;;
            u) list_iam_users "$project_id" ;;
            s) list_iam_service_accounts "$project_id" ;;
            a) list_all_resources "$project_id" ;;
            \?) echo -e "${RED}Invalid option: -$OPTARG${NC}" >&2; exit 1 ;;
        esac
        done
}

main "$@"
