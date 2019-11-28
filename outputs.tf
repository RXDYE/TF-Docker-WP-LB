output "public_ip_address" {
  description = "server public ip"
  value       = "${azurerm_public_ip.main.*.ip_address}"
}