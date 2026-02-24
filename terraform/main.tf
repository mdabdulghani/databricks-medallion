terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.30"
    }
  }
}

############################################
# Azure Provider (Service Principal Auth)
############################################

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

############################################
# Resource Group
############################################

resource "azurerm_resource_group" "rg" {
  name     = "rg-medallion"
  location = "Central India"
}

############################################
# Databricks Workspace
############################################

resource "azurerm_databricks_workspace" "ws" {
  name                = "medallion-dbx"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "standard"
}

############################################
# Databricks Provider (AAD Auth)
############################################

provider "databricks" {
  host = azurerm_databricks_workspace.ws.workspace_url

  azure_client_id     = var.client_id
  azure_client_secret = var.client_secret
  azure_tenant_id     = var.tenant_id
}

############################################
# Databricks Job (Modern Syntax)
############################################

resource "databricks_job" "medallion" {
  name = "medallion-pipeline"

  task {
    task_key = "main-task"

    new_cluster {
      spark_version = "13.3.x-scala2.12"
      num_workers   = 1
      node_type_id  = "Standard_DS3_v2"
    }

    notebook_task {
      notebook_path = "/Shared/medallion/src/main"
    }
  }

  depends_on = [
    azurerm_databricks_workspace.ws
  ]
}