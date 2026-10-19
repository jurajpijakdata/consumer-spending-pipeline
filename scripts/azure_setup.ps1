# Azure setup for consumer-spending-pipeline.
# Run step by step after `az login`. Creates everything in one resource group.

# 1. Resource group: the project folder (EU region)
az group create --name rg-consumer-spending-pipeline --location germanywestcentral

# 2. Storage account: the landing zone (cheapest tier, no anonymous access, TLS 1.2)
az storage account create --name stconsumerspendjp --resource-group rg-consumer-spending-pipeline --location germanywestcentral --sku Standard_LRS --kind StorageV2 --allow-blob-public-access false --min-tls-version TLS1_2

# 3. Data role for me: read/write files in this storage account only (least privilege)
$me = az ad signed-in-user show --query id -o tsv
$scope = az storage account show --name stconsumerspendjp --resource-group rg-consumer-spending-pipeline --query id -o tsv
az role assignment create --assignee $me --role "Storage Blob Data Contributor" --scope $scope

# 4. Container "raw": the landing zone for the original file (login, no keys)
az storage container create --name raw --account-name stconsumerspendjp --auth-mode login

# 5. Upload the original file to the landing zone (login, no keys)
az storage blob upload --account-name stconsumerspendjp --container-name raw --file data/raw/amazon-purchases.csv --name amazon-purchases.csv --auth-mode login
