#!/bin/bash
set -e

# Usage: ./deploy_db.sh <env>
# <env>: dev, qa, prod

ENV=$1
ADMIN_USER="sqladmin"
DB_NAME="sqldb-familytree"

if [[ -z "$ENV" ]]; then
    echo "Usage: ./deploy_db.sh <env>"
    exit 1
fi

case $ENV in
    dev) RG_NAME="rg-familytree-dev" ;;
    qa) RG_NAME="rg-familytree-qa" ;;
    prod) RG_NAME="rg-familytree-prod" ;;
    *) echo "Invalid environment"; exit 1 ;;
esac

echo "Deploying to $ENV (RG: $RG_NAME)..."

# 1. Get Key Vault and Retrieve Password
echo "Retrieving password from Key Vault..."
KV_NAME=$(az keyvault list --resource-group "$RG_NAME" --query "[0].name" -o tsv)

if [[ -z "$KV_NAME" ]]; then
    echo "Error: No Key Vault found in resource group $RG_NAME"
    exit 1
fi

echo "Found Key Vault: $KV_NAME"
ADMIN_PASS=$(az keyvault secret show --vault-name "$KV_NAME" --name "sql-admin-password" --query "value" -o tsv)

if [[ -z "$ADMIN_PASS" ]]; then
    echo "Error: Could not retrieve 'sql-admin-password' from Key Vault."
    exit 1    
fi

# 2. Find SQL Server Name in the RG
# Assuming only one SQL Server in the RG
SERVER_NAME=$(az sql server list --resource-group "$RG_NAME" --query "[0].name" -o tsv)

if [[ -z "$SERVER_NAME" ]]; then
    echo "Error: No SQL Server found in resource group $RG_NAME"
    exit 1
fi

FQDN="$SERVER_NAME.database.windows.net"
echo "Target: $FQDN (Database: $DB_NAME)"

# 2. Iterate and Execute Scripts
# Requires sqlcmd. 
# Installing sqlcmd on Mac: brew install microsoft-sql-ops-cli or similar.
# Or use mssql-tools.

if ! command -v sqlcmd &> /dev/null; then
    echo "Error: sqlcmd is not installed or not in PATH."
    echo "Install with: brew install mssql-tools18"
    exit 1
fi

# DATABASE Directory
DB_DIR="../database"
if [[ ! -d "$DB_DIR" ]]; then
    DB_DIR="database" 
fi

FILES=("01_schema.sql" "02_procedures.sql" "05_indexes.sql")

if [[ "$ENV" != "prod" ]]; then
    FILES+=("03_test_data.sql" "04_test_procedures.sql")
    echo "Including test data and procedures for $ENV environment."
else
    echo "Skipping test data for PROD environment."
fi

for FILE in "${FILES[@]}"; do
    FILE_PATH="$DB_DIR/$FILE"
    echo "Executing $FILE..."
    sqlcmd -S "$FQDN" -d "$DB_NAME" -U "$ADMIN_USER" -P "$ADMIN_PASS" -i "$FILE_PATH" -b
done

echo "Deployment complete for $ENV."
