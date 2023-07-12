resource "azurerm_resource_group" "app" {
  for_each = toset(var.locations)

  name     = format("rg-app-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)
  location = each.value

  tags = var.tags
}

resource "azurerm_service_plan" "app" {
  for_each = toset(var.locations)

  name = format("app-%s-%s-%s", random_id.environment_id.hex, var.environment, each.value)

  resource_group_name = azurerm_resource_group.app[each.value].name
  location            = azurerm_resource_group.app[each.value].location

  os_type  = "Linux"
  sku_name = "P1v2"
}
