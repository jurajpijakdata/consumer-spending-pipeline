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

# 6. SQL server: Entra-only login, me as admin (no SQL passwords)
$me = az ad signed-in-user show --query id -o tsv
az sql server create --name sql-consumerspend-jp --resource-group rg-consumer-spending-pipeline --location germanywestcentral --enable-ad-only-auth --external-admin-principal-type User --external-admin-name juraj.pijak.data@gmail.com --external-admin-sid $me

# 7. Firewall: Azure services (for Data Factory) and my current IP
az sql server firewall-rule create -g rg-consumer-spending-pipeline -s sql-consumerspend-jp -n AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
$myip = (Invoke-RestMethod https://api.ipify.org)
az sql server firewall-rule create -g rg-consumer-spending-pipeline -s sql-consumerspend-jp -n home-pc --start-ip-address $myip --end-ip-address $myip

# 8. Database: free offer, serverless, pauses when the free amount is used up
az sql db create -g rg-consumer-spending-pipeline -s sql-consumerspend-jp -n sqldb-consumerspend --edition GeneralPurpose --compute-model Serverless --family Gen5 --capacity 2 --use-free-limit --free-limit-exhaustion-behavior AutoPause
