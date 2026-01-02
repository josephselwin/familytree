#!/bin/bash
set -e

# Usage: ./create_infra.sh <env> [optional: service-principal-object-id]
# <env> can be: dev, qa, prod

ENV=$1
SP_OBJECT_ID=$2
LOCATION="eastus"
ADMIN_USER="sqladmin"
DB_NAME="sqldb-familytree"

if [[ -z "$ENV" ]]; then
    echo "Usage: ./create_infra.sh <env> [optional: service-principal-object-id]"
    exit 1
fi

case $ENV in
    dev)
        SUB_NAME="sub-dev"
        RG_NAME="rg-familytree-dev"
        ;;
    qa)
        SUB_NAME="sub-qa"
        RG_NAME="rg-familytree-qa"
        ;;
    prod)
        SUB_NAME="sub-prod"
        RG_NAME="rg-familytree-prod"
        ;;
    *)
        echo "Invalid environment. Choose dev, qa, or prod."
        exit 1
        ;;
esac

# Generate unique suffix for global resources (Server, KV)
SUFFIX=$RANDOM
SERVER_NAME="sql-familytree-$ENV-$SUFFIX"
KV_NAME="kv-familytree-$ENV-$SUFFIX"

echo "------------------------------------------------"
echo "Deploying to Environment: $ENV"
echo "Subscription: $SUB_NAME"
echo "Resource Group: $RG_NAME"
echo "Region: $LOCATION"
echo "Key Vault: $KV_NAME"
echo "SQL Server: $SERVER_NAME"
echo "------------------------------------------------"

# 1. Set Subscription
echo "Setting subscription..."
# Attempting to set if it exists in list
if az account list --query "[?name=='$SUB_NAME']" | grep -q "$SUB_NAME"; then
    az account set --subscription "$SUB_NAME"
else
    echo "Warning: Subscription '$SUB_NAME' not found. creating resources in current subscription."
fi

# 2. Create Resource Group
echo "Creating Resource Group..."
az group create --name "$RG_NAME" --location "$LOCATION"

# 3. Create Key Vault
echo "Creating Key Vault..."
az keyvault create --name "$KV_NAME" --resource-group "$RG_NAME" --location "$LOCATION"

# 3b. Grant Permissions to Service Principal (if provided)
if [[ -n "$SP_OBJECT_ID" ]]; then
    echo "Granting 'get' and 'list' secret permissions to Service Principal ($SP_OBJECT_ID)..."
    az keyvault set-policy --name "$KV_NAME" --object-id "$SP_OBJECT_ID" --secret-permissions get list
fi

# 4. Generate and Store Password
echo "Generating Admin Password..."
# Generate a strong password (16 chars, alphanumeric + special)
ADMIN_PASS=$(openssl rand -base64 16)
# Ensure it meets complexity if needed (Azure SQL usually requires 3 categories). Base64 usually works.

echo "Storing Password in Key Vault..."
az keyvault secret set --vault-name "$KV_NAME" --name "sql-admin-password" --value "$ADMIN_PASS"

# 5. Create SQL Server
echo "Creating SQL Server..."
az sql server create \
    --name "$SERVER_NAME" \
    --resource-group "$RG_NAME" \
    --location "$LOCATION" \
    --admin-user "$ADMIN_USER" \
    --admin-password "$ADMIN_PASS"

# 6. Create SQL Database
echo "Creating SQL Database..."
az sql db create \
    --resource-group "$RG_NAME" \
    --server "$SERVER_NAME" \
    --name "$DB_NAME" \
    --service-objective Basic

# 7. Open Firewall
echo "Configuring Firewall..."
az sql server firewall-rule create \
    --resource-group "$RG_NAME" \
    --server "$SERVER_NAME" \
    --name AllowAzureServices \
    --start-ip-address 0.0.0.0 \
    --end-ip-address 0.0.0.0

echo "Infrastructure creation complete."
echo "Key Vault: $KV_NAME"
echo "SQL Server FQDN: $SERVER_NAME.database.windows.net"
echo "Admin User: $ADMIN_USER"
echo "Password stored in Key Vault secret: 'sql-admin-password'"
if [[ -n "$SP_OBJECT_ID" ]]; then
    echo "Access granted to Service Principal: $SP_OBJECT_ID"
fi
