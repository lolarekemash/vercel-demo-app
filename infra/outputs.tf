output "webapp_name" {
  value = azurerm_linux_web_app.app.name
}

output "webapp_url" {
  value = azurerm_linux_web_app.app.default_hostname
}

output "appinsights_connection_string" {
  value     = azurerm_application_insights.appinsights.connection_string
  sensitive = true
}
