#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Flags for checking installed versions, using an associative array
# The key is the package name and the value is the flag to use to check the version
# Add packages to install here
declare -A package_version_flags=(
    ["jq"]="--version"
    ["terraform"]="--version"
    ["packer"]="--version"
    ["vagrant"]="--version"
    ["ansible"]="--version"
    ["gh"]="--version"
    ["httpie"]="--version"
)

# Help message
function show_help() {
    echo -e "Usage: $0 [flags] [package_name] [version]"
    echo "Flags:"
    echo "  -h: Show help and usage information"
    echo "  -i: Install a package"
    echo "  -c: Check installed versions of packages"
    echo "If no flags are provided, the script will install all packages from the list."
}

# Check if a package is installed and return its version
function is_installed() {
  package_name="$1"
  version_flag="${package_version_flags[$package_name]}"

  version=$($package_name $version_flag 2>/dev/null)
  return_code=$?

  if [ $return_code -eq 0 ]; then
    echo "$version"
    return 0
  else
    return 1
  fi
}

# Install a package 
function install_package() {
    package_name="$1"
    package_version="$2"

    if is_installed "$package_name"; then
        echo -e "${RED}$package_name is already installed. Skipping installation.${NC}"
    else
        echo -e "${GREEN}Installing $package_name...${NC}"
        case "$package_name" in
            jq)
                brew install jq
                ;;
            terraform)
                brew tap hashicorp/tap
                brew install hashicorp/tap/terraform
                ;;
            packer)
                brew tap hashicorp/tap
                brew install hashicorp/tap/packer
                ;;
            vagrant)
                brew tap hashicorp/tap
                brew install hashicorp/tap/hashicorp-vagrant
                ;;
            ansible)
                brew install ansible
                ;;
            gh)
                brew install gh
                ;;
            httpie)
                brew install httpie
                ;;
            *)
                echo -e "${RED}Unknown package: $package_name${NC}"
                ;;
        esac
        echo -e "${GREEN}$package_name installed.${NC}"
    fi
}

# Check installed versions
function check_versions() {
  for package in "${!package_version_flags[@]}"; do
    version=$(is_installed "$package")
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}$package: $version${NC}"
    else
      echo -e "${RED}$package: Not installed${NC}"
    fi
  done
}

# Install all packages from the list
function install_all_packages() {
  for package_name in "${!package_version_flags[@]}"; do
    version=$(is_installed "$package_name")
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}$package_name is already installed: ${YELLOW}$version${NC}"
    else
      echo -e "${RED}$package_name not installed. Installing now...${NC}"
      install_package $package_name
    fi
  done
}

# Parse arguments
if [ $# -eq 0 ]; then
    install_all_packages
    exit 0
fi

while getopts ":hic" flag; do
    case $flag in
        h)  show_help; exit 0 ;;
        i)
            if [ $# -lt 2 ]; then
                echo -e "${RED}Error: Missing package name.${NC}"
                show_help
                exit 1
            fi
            package_name="${!OPTIND}"
            package_version="${!OPTIND+1}"
            install_package "$package_name" "$package_version"
            exit 0
            ;;
        c)  check_versions
            exit 0 
            ;;
        \?)
            echo -e "${RED}Invalid option: -${OPTARG}${NC}" >&2
            show_help
            exit 1
            ;;
    esac
done
