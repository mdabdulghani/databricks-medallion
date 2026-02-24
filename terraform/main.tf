terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "databricks" {
  host = azurerm_databricks_workspace.ws.workspace_url
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-medallion"
  location = "Central India"
}

resource "azurerm_storage_account" "lake" {
  name                     = "medallionlake123"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_databricks_workspace" "ws" {
  name                = "medallion-dbx"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "standard"
}

resource "databricks_job" "medallion" {
  name = "medallion-pipeline"

  new_cluster {
    spark_version = "13.3.x-scala2.12"
    num_workers   = 1
    node_type_id = "Standard_DS3_v2"
  }

  notebook_task {
    notebook_path = "/Shared/medallion/src/main"
  }
}