1. Prerequisites
An active Azure Subscription.

Azure CLI installed locally.

A GitHub Repository named devops-infra-cluster.

2. Infrastructure Setup Steps
Step A: Azure Environment Preparation
Login to Azure:

Bash
az login
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
Create State Storage (Remote Backend):
We use an Azure Storage Account to securely store the Terraform state file, enabling state locking and collaboration.

Bash
# Create Resource Group
az group create --name devops-state-rg --location eastus
# Create Storage Account
az storage account create --name devopsstateaccount --resource-group devops-state-rg --location eastus --sku Standard_LRS
# Create Container
az storage container create --name terraform-state --account-name devopsstateaccount --auth-mode login
Step B: GitHub Actions Authentication
To allow GitHub to manage your Azure resources, create a Service Principal:

Bash
az ad sp create-for-rbac --name "github-actions-devops" --role contributor --scopes /subscriptions/<YOUR_SUBSCRIPTION_ID>
Save the output (JSON).

Add the following as GitHub Secrets (Settings > Secrets and variables > Actions):

AZURE_CLIENT_ID

AZURE_CLIENT_SECRET

AZURE_SUBSCRIPTION_ID

AZURE_TENANT_ID

3. Repository Structure
main.tf: Core AKS cluster resource definition.

providers.tf: Provider settings and Remote Backend configuration.

variables.tf: Configurable inputs (region, node count, VM size).

.github/workflows/terraform.yml: CI/CD pipeline for automated plan and apply.

.gitignore: Prevents sensitive state files and local config from being committed.

4. Automation Workflow
Every time you push code to main, the GitHub Action performs:

Terraform Init: Initializes the backend and providers.

Terraform Plan: Generates an execution plan for changes.

Terraform Apply: Provisions the infrastructure on Azure.

5. Usage
To modify the infrastructure, edit variables.tf, commit your changes, and push:

Bash
git add .
git commit -m "Updated infrastructure configuration"
git push origin main


az role assignment create \
  --assignee cb1e40d3-1d9f-412d-8ad4-8aacfdf38e55 \
  --role "Storage Blob Data Contributor" \
  --scope /subscriptions/<>/resourceGroups/devops-state-rg/providers/Microsoft.Storage/storageAccounts/devopsstateaccount


  ==================================================================

  This is the comprehensive, start-to-finish roadmap to setting up your DevOps environment from scratch, including the critical identity management and backend security steps.

Phase 1: Local Environment & Authentication
Before you can interact with Azure, you must install the tools and establish your identity.

Install Tools:

Azure CLI: Download and install the Azure CLI.

Terraform: Download and install Terraform.

Authenticate Locally:

Run az login in your terminal and follow the browser prompts to sign into your Azure account.

Create Service Principal (The CI/CD Identity):

Run the following to create the "robot" identity for GitHub:

Bash
az ad sp create-for-rbac --name "github-actions-devops" --role contributor --scopes /subscriptions/<YOUR_SUBSCRIPTION_ID>
CRITICAL: Save the output (JSON). You must copy the appId (Client ID), password (Client Secret), and tenant (Tenant ID).

Phase 2: Remote State Backend (Azure Storage)
Terraform needs a secure, centralized location to store the state file so that your local machine and your GitHub Actions pipeline both see the same infrastructure reality.

Create Resources:

Bash
az group create --name devops-state-rg --location eastus
az storage account create --name devopsstateaccount --resource-group devops-state-rg --location eastus --sku Standard_LRS
az storage container create --name terraform-state --account-name devopsstateaccount --auth-mode login
Set Permissions:

Get your App ID: az ad sp list --display-name "github-actions-devops" --query "[0].appId" -o tsv

Grant the Identity access:

Bash
az role assignment create --assignee <YOUR_APP_ID> --role "Storage Blob Data Contributor" --scope /subscriptions/<SUB_ID>/resourceGroups/devops-state-rg/providers/Microsoft.Storage/storageAccounts/devopsstateaccount
Phase 3: Security & GitHub Integration
Never hardcode credentials in your files. You must store them in GitHub to allow secure automated deployments.

Open GitHub Repo: Go to Settings > Secrets and variables > Actions.

Add Secrets: Create these four keys with the values you saved in Phase 1:

AZURE_CLIENT_ID

AZURE_CLIENT_SECRET

AZURE_TENANT_ID

AZURE_SUBSCRIPTION_ID

Phase 4: Terraform Implementation
Configure your infrastructure files while respecting the Azure constraints discovered during your setup.

Register Provider: You must enable the AKS service in your subscription:

Bash
az provider register --namespace Microsoft.ContainerService
Configure main.tf: Ensure your node pool uses an allowed SKU (e.g., Standard_D2s_v7) based on your region's quota.

Configure Backend (providers.tf):

Terraform
terraform {
  backend "azurerm" {
    resource_group_name  = "devops-state-rg"
    storage_account_name = "devopsstateaccount"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
  }
}
Phase 5: The Execution Loop
Now that the configuration is in place, this is your daily development lifecycle:

Code: Edit your .tf files locally.

Plan/Verify: Run terraform plan locally to check for errors.

Commit/Push: Use git add ., git commit -m "...", and git push origin main.

Automate: GitHub Actions automatically triggers, runs terraform init, plan, and apply.

Clean Up: To remove all costs when finished, run terraform destroy -auto-approve (or trigger it via the pipeline).

Troubleshooting Summary
Access Denied: Double-check your "Storage Blob Data Contributor" role assignment.

409 Conflict: You forgot to register the required provider (e.g., Microsoft.ContainerService).

400 Bad Request: You are using a VM SKU not permitted by your subscription's quota—check the error list and pick an allowed v7 SKU.


Now connect to cluster:
az aks get-credentials --resource-group devops-project-rg --name devops-cluster --overwrite-existing


and get nodes:
k get nodes