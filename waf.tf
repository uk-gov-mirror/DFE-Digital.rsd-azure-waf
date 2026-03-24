module "waf" {
  source = "github.com/DFE-Digital/terraform-azurerm-front-door-app-gateway-waf?ref=v1.6.1"

  environment    = local.environment
  project_name   = local.project_name
  azure_location = local.azure_location

  response_request_timeout = local.response_request_timeout

  virtual_network_address_space = local.virtual_network_address_space

  waf_targets = local.waf_targets

  enable_waf       = local.enable_waf
  waf_application  = local.waf_application
  waf_mode         = local.waf_mode
  waf_custom_rules = local.waf_custom_rules

  restrict_app_gateway_v2_to_front_door_inbound_only = local.restrict_app_gateway_v2_to_front_door_inbound_only

  app_gateway_v2_enable_private_link             = true
  app_gateway_v2_waf_managed_rulesets            = local.app_gateway_v2_waf_managed_rulesets
  app_gateway_v2_waf_managed_rulesets_exclusions = local.app_gateway_v2_waf_managed_rulesets_exclusions
  app_gateway_v2_waf_request_body_enforcement    = false

  enable_key_vault_app_gateway_certificates = false

  cdn_add_response_headers    = local.cdn_add_response_headers
  cdn_remove_response_headers = local.cdn_remove_response_headers

  existing_logic_app_workflow = local.existing_logic_app_workflow
  monitor_email_receivers     = local.monitor_email_receivers

  tags = local.tags
}
