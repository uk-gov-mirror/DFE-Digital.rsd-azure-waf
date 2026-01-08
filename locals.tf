locals {
  environment     = var.environment
  project_name    = var.project_name
  azure_location  = var.azure_location
  resource_prefix = "${local.environment}${local.project_name}"

  tfvars_filename     = var.tfvars_filename
  tfvars_access_ipv4  = var.tfvars_access_ipv4
  waf_tfvars_filename = var.waf_tfvars_filename

  existing_logic_app_workflow = var.existing_logic_app_workflow
  monitor_email_receivers     = var.monitor_email_receivers

  virtual_network_address_space = var.virtual_network_address_space

  response_request_timeout = var.response_request_timeout
  container_app_targets    = var.container_app_targets
  web_app_service_targets  = var.web_app_service_targets
  windows_web_app_service_targets = {
    for web_app_service_target_name, web_app_service_target_value in local.web_app_service_targets : web_app_service_target_name => web_app_service_target_value if web_app_service_target_value.os == "Windows"
  }
  linux_web_app_service_targets = {
    for web_app_service_target_name, web_app_service_target_value in local.web_app_service_targets : web_app_service_target_name => web_app_service_target_value if web_app_service_target_value.os == "Linux"
  }
  waf_targets = merge(
    {
      for container_app_target_name, container_app_target_value in local.container_app_targets : replace(container_app_target_name, local.environment, "") => merge(
        {
          domain = data.azurerm_container_app.container_apps[container_app_target_name].ingress[0].fqdn
        },
        container_app_target_value
      )
    },
    {
      for windows_web_app_service_target_name, windows_web_app_service_target_value in local.windows_web_app_service_targets : replace(windows_web_app_service_target_name, local.environment, "") => merge(
        {
          domain = data.azurerm_windows_web_app.web_apps[windows_web_app_service_target_name].default_hostname
        },
        windows_web_app_service_target_value
      )
    },
    {
      for linux_web_app_service_target_name, linux_web_app_service_target_value in local.linux_web_app_service_targets : replace(linux_web_app_service_target_name, local.environment, "") => merge(
        {
          domain = data.azurerm_linux_web_app.web_apps[linux_web_app_service_target_name].default_hostname
        },
        linux_web_app_service_target_value
      )
    }
  )

  cdn_add_response_headers    = var.cdn_add_response_headers
  cdn_remove_response_headers = var.cdn_remove_response_headers

  restrict_app_gateway_v2_to_front_door_inbound_only = var.restrict_app_gateway_v2_to_front_door_inbound_only

  enable_waf       = var.enable_waf
  waf_application  = var.waf_application
  waf_mode         = var.waf_mode
  waf_custom_rules = var.waf_custom_rules

  app_gateway_v2_waf_managed_rulesets            = var.app_gateway_v2_waf_managed_rulesets
  app_gateway_v2_waf_managed_rulesets_exclusions = var.app_gateway_v2_waf_managed_rulesets_exclusions

  custom_error_web_page_storage_accounts = { for storage in module.waf.custom_error_web_page_storage_accounts : storage.name => storage.primary_web_endpoint }

  custom_error_web_pages = { for k, v in local.custom_error_web_page_storage_accounts :
    k => {
      "govuk/403.html" : templatefile(
        "${path.root}/error-response-page/templates/govuk/403.html.tftpl", {
          base_url : trim(v, "/")
          title : "403 - Forbidden"
        }
      ),
      "govuk/502.html" : templatefile(
        "${path.root}/error-response-page/templates/govuk/502.html.tftpl", {
          base_url : trim(v, "/")
          title : "502 - Bad Gateway"
        }
      )
      "dfe/403.html" : templatefile(
        "${path.root}/error-response-page/templates/dfe/403.html.tftpl", {
          base_url : trim(v, "/")
          title : "403 - Forbidden"
        }
      ),
      "dfe/502.html" : templatefile(
        "${path.root}/error-response-page/templates/dfe/502.html.tftpl", {
          base_url : trim(v, "/")
          title : "502 - Bad Gateway"
        }
      )
    }
  }

  is_windows = can(regex("^[A-Za-z]:", abspath(path.root)))
  bash       = local.is_windows ? "C:/Program Files/Git/bin/bash.exe" : "/bin/bash"

  tags = var.tags
}
