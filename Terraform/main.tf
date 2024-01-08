module "west_webapp" {
  source                = "./modules/app_service"
  rg_name               = "west_rg-${var.environment}"
  location              = "West Europe"
  app_service_plan_name = "WestServicePlan-${var.environment}"
  app_service_name      = "WestWebApp-${var.environment}"
  repo_url              = "https://github.com/Selmouni-Abdelilah/WebApplication_West.git"
  branch                = "main"
}

module "east_webapp" {
  source                = "./modules/app_service"
  rg_name               = "east_rg-${var.environment}"
  location              = "East US"
  app_service_plan_name = "EastServicePlan-${var.environment}"
  app_service_name      = "EastWebApp-${var.environment}"
  repo_url              = "https://github.com/Selmouni-Abdelilah/WebApplication_East.git"
  branch                = "main"
}
module "west_network" {
  source            = "./modules/Network"
  rg_name              = "west_rg-${var.environment}"
  location          = "West Europe"
  vnet_name         = "vnet-westus-${var.environment}"
  public_ip_name    = "ip-westus-${var.environment}"
  domain_name       = "ipwestus${var.environment}"
}

module "east_network" {
  source            = "./modules/Network"
  rg_name              = "east_rg-${var.environment}"
  location          = "East US"
  vnet_name         = "vnet-eastus-${var.environment}"
  public_ip_name    = "ip-eastus-${var.environment}"
  domain_name       = "ipeastus${var.environment}"
}
module "west_app_gateway" {
  source               = "./modules/app_gateway"
  name                 = "app-gateway-westus-${var.environment}"
  rg_name              = "west_rg-${var.environment}"
  location             = "West Europe"
  vnet_subnet_id       = module.west_network.subnet_id
  public_ip_id         = module.west_network.public_ip_id
  app_service_fqdn     = module.west_webapp.webapp_name
}

module "east_app_gateway" {
  source               = "./modules/app_gateway"
  name                 = "app-gateway-eastus-${var.environment}"
  rg_name              = "east_rg-${var.environment}"
  location             = "East US"
  vnet_subnet_id       = module.east_network.subnet_id
  public_ip_id         = module.east_network.public_ip_id
  app_service_fqdn     = module.east_webapp.webapp_name
}
module "traffic_manager" {
  source                    = "./modules/traffic_manager"
  name                      = "vterra-traffic-profile-${var.environment}"
  location                  = "Central US"
  rg_name                   = "traffic_manager_rg-${var.environment}"
  profile_name              = "vterra-traffic-profile-${var.environment}"
  ttl                       = 100
  monitor_protocol          = "HTTPS"
  monitor_port              = 443
  monitor_path              = "/"
  monitor_interval          = 30
  monitor_timeout           = 10
  monitor_failures          = 2
  primary_target_resource_id = module.east_network.public_ip_id
  secondary_target_resource_id = module.west_network.public_ip_id
}