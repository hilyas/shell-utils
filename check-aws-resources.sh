#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Defaults
AWS_PROFILE=""
AWS_REGION=""
ACTION=""

# Show help message
function show_help() {
    echo -e "Usage: check-aws-resources.sh [flags] [--profile PROFILE_NAME] [--region REGION]"
    echo -e "Example: ./check-aws-resources.sh -esri --profile sandbox-admin --region us-west-2"
    echo -e "Options:"
    echo "  --profile PROFILE_NAME: Specify the AWS profile to use"
    echo "  --region REGION: Specify the AWS region to use"
    echo "Flags:"
    echo "  -h: Show help and usage information"
    echo "  -e: List EC2 instances"
    echo "  -s: List S3 buckets"
    echo "  -r: List RDS instances"
    echo "  -i: List IAM users"
    echo "  -a: List all resources"
}

# Function to list EC2 instances
function list_ec2_instances() {
    echo -e "${GREEN}Listing EC2 instances:${NC}"
    instances=$(aws $AWS_PROFILE $AWS_REGION ec2 describe-instances \
        --query "Reservations[*].Instances[*].{
                    InstanceID: InstanceId,
                    Type: InstanceType,
                    State: State.Name,
                    PublicIP: PublicIpAddress,
                    PrivateIP: PrivateIpAddress,
                    VPC: VpcId,
                    Subnet: SubnetId,
                    KeyName: KeyName,
                    AMI: ImageId,
                    SGs: join(', ', SecurityGroups[].GroupName),
                    AZ: Placement.AvailabilityZone}" \
        --output table)
    check_aws_output "$instances" "EC2 instances"
}

# Function to list S3 buckets
function list_s3_buckets() {
    echo -e "${GREEN}Listing S3 buckets:${NC}"
    buckets=$(aws $AWS_PROFILE $AWS_REGION s3api list-buckets \
        --query "Buckets[].{Name:Name, CreationDate:CreationDate}" \
        --output table)
    check_aws_output "$buckets" "S3 buckets"
}

# Function to list RDS instances
function list_rds_instances() {
    echo -e "${GREEN}Listing RDS instances:${NC}"
    instances=$(aws $AWS_PROFILE $AWS_REGION rds describe-db-instances \
        --query "DBInstances[*].{
                    DBInstanceIdentifier:DBInstanceIdentifier,
                    DBInstanceClass:DBInstanceClass,
                    Engine:Engine,
                    EngineVersion:EngineVersion,
                    DBInstanceStatus:DBInstanceStatus,
                    MasterUsername:MasterUsername,
                    Endpoint:Endpoint.Address,
                    AllocatedStorage:AllocatedStorage,
                    VpcId:DBSubnetGroup.VpcId,
                    MultiAZ:MultiAZ,
                    StorageType:StorageType,
                    PubliclyAccessible:PubliclyAccessible}" \
        --output table)
    check_aws_output "$instances" "RDS instances"
}

# Function to list IAM users
function list_iam_users() {
    echo -e "${GREEN}Listing IAM users:${NC}"
    iam_users=$(aws $AWS_PROFILE $AWS_REGION iam list-users \
        --query "Users[*].UserName" \
        --output text)
    check_aws_output "$iam_users" "IAM users"
}

# Function to check if the output is empty and handle errors
function check_aws_output() {
    output="$1"
    resource_type="$2"

    if [ $? -ne 0 ]; then
        echo -e "${RED}Error occurred while listing ${resource_type}.${NC}"
        return 1
    elif [[ -z "$output" ]]; then
        echo -e "${YELLOW}There are no ${resource_type}.${NC}"
    else
        echo "$output"
    fi
}

# Function to list all AWS resources
function list_all_resources() {
    list_ec2_instances
    echo ""
    list_s3_buckets
    echo ""
    list_rds_instances
    echo ""
    list_iam_users
    echo ""
}

# Main function to handle script execution
function main() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            -h) ACTION="show_help"; shift ;;
            -e) ACTION="list_ec2_instances"; shift ;;
            -s) ACTION="list_s3_buckets"; shift ;;
            -r) ACTION="list_rds_instances"; shift ;;
            -i) ACTION="list_iam_users"; shift ;;
            -a) ACTION="list_all_resources"; shift ;;
            --profile) 
                AWS_PROFILE="--profile $2"
                shift 2
                ;;
            --region) 
                AWS_REGION="--region $2"
                shift 2
                ;;
            *) 
                echo -e "${RED}Invalid option: $1${NC}" >&2
                show_help
                exit 1
                ;;
        esac
    done

    if [ -z "$ACTION" ]; then
        show_help
        return 1
    fi

    $ACTION
}

main "$@"
