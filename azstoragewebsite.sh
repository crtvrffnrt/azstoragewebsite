#!/bin/bash

# Function to display messages with colors
display_message() {
    local message="$1"
    local color="$2"
    case $color in
        red) echo -e "\033[91m${message}\033[0m" ;;
        green) echo -e "\033[92m${message}\033[0m" ;;
        yellow) echo -e "\033[93m${message}\033[0m" ;;
        blue) echo -e "\033[94m${message}\033[0m" ;;
        cyan) echo -e "\033[96m${message}\033[0m" ;;
        *) echo "$message" ;;
    esac
}

# Function to check Azure authentication
check_azure_authentication() {
    az account show &> /dev/null
    if [ $? -ne 0 ]; then
        display_message "Please authenticate to your Azure account using 'az login --use-device-code'." "red"
        exit 1
    fi
}

# Function to delete old resource groups created by this script
delete_old_resource_groups() {
    az group list --query "[?starts_with(name, 'StaticPhishlet')].name" -o tsv | while read -r group; do
        az group delete --name "$group" --yes --no-wait &> /dev/null
        if [ $? -eq 0 ]; then
            display_message "Successfully deleted resource group $group." "green"
        else
            display_message "Failed to delete resource group $group." "red"
        fi
    done
}

# Main script execution
main() {
    local index_file=""
    local examplename=""

    # Parse arguments
    while getopts "i:n:" opt; do
        case $opt in
            i) index_file="$OPTARG" ;;
            n) examplename="$OPTARG" ;;
            *)
                display_message "Invalid option provided. Use -i for index file and -n for name." "red"
                exit 1
                ;;
        esac
    done

    # Validate inputs
    if [ -z "$index_file" ] || [ -z "$examplename" ]; then
        display_message "Both -i (index file) and -n (name) must be provided." "red"
        exit 1
    fi

    if [ ! -f "$index_file" ]; then
        display_message "The specified index file '$index_file' does not exist." "red"
        exit 1
    fi

    # Check Azure authentication
    check_azure_authentication

    # Generate unique storage account name
    local unique_id=$(date +%s | tail -c 6)
    local storage_account_name="${examplename,,}$unique_id"
    local resource_group_name="StaticPhishlet-${examplename,,}-rg-$unique_id"

    # Delete old resource groups
    delete_old_resource_groups

    # Create resource group
    display_message "Creating resource group '$resource_group_name'..." "blue"
    az group create --name "$resource_group_name" --location "eastus" > /dev/null
    display_message "Resource group '$resource_group_name' created successfully." "green"

    # Create storage account
    display_message "Creating storage account '$storage_account_name'..." "blue"
    az storage account create \
        --name "$storage_account_name" \
        --resource-group "$resource_group_name" \
        --location "eastus" \
        --sku "Standard_LRS" > /dev/null

    if [ $? -ne 0 ]; then
        display_message "Failed to create storage account." "red"
        exit 1
    fi

    # Enable static website hosting
    display_message "Enabling static website hosting for '$storage_account_name'..." "blue"
    az storage blob service-properties update \
        --account-name "$storage_account_name" \
        --static-website \
        --index-document "index.html" &> /dev/null

    if [ $? -ne 0 ]; then
        display_message "Failed to enable static website hosting." "red"
        exit 1
    fi

    # Upload index.html to $web container
    local web_container_name="\$web"
    display_message "Uploading index.html to the static website container..." "blue"
    az storage blob upload \
        --account-name "$storage_account_name" \
        --container-name "$web_container_name" \
        --name "index.html" \
        --file "$index_file" &> /dev/null

    if [ $? -ne 0 ]; then
        display_message "Failed to upload index.html." "red"
        exit 1
    fi

    # Retrieve the static website URL
    local static_website_url="https://${storage_account_name}.z13.web.core.windows.net/"
    display_message "Static website deployed successfully!" "green"
    display_message "Your website is available at: $static_website_url" "cyan"
}

main "$@"
