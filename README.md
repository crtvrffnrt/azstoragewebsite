# Azure Static Website Deployment Script

This repository contains a Bash script to automate the deployment of a static website to Azure Storage. The script sets up an Azure Storage account with static website hosting enabled, uploads your `index.html` file, and provides the public URL for accessing the website.

## Features

- Automatically creates and configures an Azure Storage account for static website hosting.
- Deletes previously created resource groups starting with the prefix `StaticPhishlet`.
- Uploads an `index.html` file to the `$web` container.
- Outputs the public URL for the deployed website.

## Prerequisites

1. **Azure CLI**: Ensure that the Azure CLI is installed and authenticated. You can log in using:
   ```bash
   az login --use-device-code
   ```
2. **Bash Shell**: The script runs in a Bash environment.

## Usage

### as oneliner

```bash
az login --use-device-code && git clone https://github.com/crtvrffnrt/azstoragewebsite.git && chmod +x ./azstoragewebsite/azstoragewebsite.sh && ./azstoragewebsite/azstoragewebsite.sh -i index.html -n "CompanySupport"
```
Run the script with the following options:

```bash
./azstoragewebsite.sh -i <path-to-index-file> -n <name-prefix>
```

### Parameters
- `-i`: Path to your `index.html` file. This file will be uploaded to the storage account's static website container.
- `-n`: A unique name prefix for identifying the resource group and storage account.

### Example


```bash
./azstoragewebsite.sh -i index.html -n Company
```

### Output
The script will display the public URL of your static website:

```bash
Static website deployed successfully!
Your website is available at: https://<storage_account_name>.z13.web.core.windows.net/
```

## How It Works
1. Authenticates the Azure CLI session.
2. Deletes any old resource groups starting with the prefix `StaticPhishlet`.
3. Creates a new resource group and storage account.
4. Enables static website hosting for the storage account.
5. Uploads the specified `index.html` file to the `$web` container.
6. Retrieves and displays the public URL of the static website.

## Notes
- Ensure your Azure account has sufficient permissions to create and delete resource groups and storage accounts.
- The generated storage account name is a combination of the provided prefix and a random unique identifier to ensure uniqueness.
