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