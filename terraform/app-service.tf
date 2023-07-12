resource "azurerm_resource_group" "app" {
  for_each = toset(var.locations)

  name     = format("rg-app-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)
  location = each.value

  tags = var.tags
}

resource "azurerm_service_plan" "app" {
  for_each = toset(var.locations)

  name = format("sp-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)

  resource_group_name = azurerm_resource_group.app[each.value].name
  location            = azurerm_resource_group.app[each.value].location

  os_type  = "Linux"
  sku_name = "P1v2"
}

resource "azurerm_linux_web_app" "app" {
  for_each = toset(var.locations)

  name = format("app-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)

  resource_group_name = azurerm_resource_group.app[each.value].name
  location            = azurerm_resource_group.app[each.value].location

  service_plan_id = azurerm_service_plan.app[each.value].id

  https_only = true

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.ai[each.value].instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.ai[each.value].connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
  }

  site_config {
    ftps_state = "Disabled"

    application_stack {
      dotnet_version = "7.0"
    }
  }
}
