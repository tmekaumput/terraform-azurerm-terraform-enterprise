# Terraform Enterprise Azure Module

## Disclaimer

This repository is based off the [commit](https://github.com/hashicorp/terraform-azurerm-terraform-enterprise/commit/e975ee34b5305cbcfdf1f5e62a9aad7cb3032710) and making modification under the MPL 2.0 license. Also, there is no intent for commercial use in this clone repository by the contributor. The repository is served as educational purpose.

**IMPORTANT**: You are viewing a **beta version** of the official
module to install Terraform Enterprise. This new version is
**incompatible with earlier versions**, and it is not currently meant
for production use. Please contact your Customer Success Manager for
details before using.

This is a Terraform module for provisioning a Terraform Enterprise Cluster on Azure. Terraform Enterprise is our self-hosted distribution of Terraform Cloud. It offers enterprises a private instance of the Terraform Cloud application, with no resource limits and with additional enterprise-grade architectural features like audit logging and SAML single sign-on.

## About This Module

This module will install Terraform Enterprise on Azure according to the [HashiCorp Reference Architecture](https://www.terraform.io/docs/enterprise/before-installing/reference-architecture/azure.html). This module is intended to be used by practitioners seeking a Terraform Enterprise installation which requires minimal configuration in the Azure cloud.

As the goal for this main module is to provide a drop-in solution for installing Terraform Enterprise via the Golden Path it leverages Azure native solutions such as Azure Database for PostgreSQL and Azure Cache for Redis. We have provided guidance and limited examples for other use cases.

## Pre-requisites

This module is intended to run in an Azure account with minimal preparation, however it does have the following prerequisites:

### Terraform version >= 0.13

- This module requires Terraform version `0.13` or greater to be installed on the running machine.

### License file

- A Terraform Enterprise license file is required, and it must be provided as a Base64 encoded secret in Azure Key Vault.

### Azure Resources

- Resource groups

  - An existing resource group can be supplied for `resource_group_name`, but it is not necessary. This existing resource group should also contain an existing DNS zone, Key Vault, and Key Vault Certificate unless stated in an example or otherwise required for a particular scenario.

- DNS

  - If you are managing DNS via Azure DNS:
    - Existing resource group with DNS zone should be supplied as `resource_group_name` or, if it exists in another resource group, `resource_group_name_dns`
    - Existing DNS zone should exist matching `domain_name`
    - Desired subdomain should be supplied as `tfe_subdomain`
    - DNS record will be created as `tfe_subdomain`.`domain_name`
  - If you are managing DNS outside of Azure DNS:
    - Module will output resulting load balancer or application gateway IP address as `load_balancer_ip`
    - You must configured external DNS record for the aforementioned IP address

- Key Vault
  - The Key Vault should have enabled access for deployment for Azure Virtual Machines, as the virtual machines will pull the certificate (and secrets, if applicable) from Key Vault.

## Azure Services Used

- Azure Active Directory
- Azure Application Gateway
- Azure Bastion
- Azure Blob Storage
- Azure Cache for Redis
- Azure Database for PostgreSQL
- Azure DNS
- Azure Key Vault
- Azure Load Balancer
- Azure Virtual Machines
- Azure Virtual Network
- Azure Resource Groups

## How to Use This Module

### Deployment

1. Clone repository to local machine
2. Change directory into desired example (such as ./examples/active_active)
3. Replace license file (./files/license.rli) with your own using the same name or modify tfe_license_filepath variable with appropriate local path
4. Authenticate against provider
   - <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli>
   - `az login`
   - `az account list`
   - `az account set --subscription="SUBSCRIPTION_ID"`
5. `terraform init`
6. `terraform plan`
7. `terraform apply`

### SSL Certificates

As stated in the [prerequisites](##Pre-requisites), there are a number
of variables concerning certificates and secrets. This section provides
additional context on the use of each of those variables.

- All of the certificate and secret resources will expect to use the
  same key vault.

- IMPORTANT: In order to keep PEM formatted secrets properly formatted,
  they must be uploaded to Key Vault via Terraform (as the whole file or
  via `az keyvault secret set`). Uploading them manually through the Azure
  Portal will result in newline formatting issues.

| Variable Name               | Variable Description                                                                                               | Explanation                                                                                                                                                                                                                                                                                                                                                                                                            |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `load_balancer_certificate` | A PFX formatted certificate found in the Azure Key Vault                                                           | **Required** <br>This certificate is used for TLS. We recommend using certificates signed by well known CA authorities. <br><br/>This certificate will be placed on the Application Gateway if that is your load balancing option. ([Reference](https://docs.microsoft.com/en-us/azure/application-gateway/ssl-overview))                                                                                              |
| `vm_certificate`            | A PFX formatted certificate found in the Azure Key Vault                                                           | **Required** <br>This certificate is used for TLS. We recommend using certificates signed by well known CA authorities. <br><br/>This certificate will be placed on the TFE instance via the virtual machine scale set. ([Reference](https://docs.microsoft.com/en-us/azure/application-gateway/ssl-overview)) <br><br/>TFE will also use this certificate in its `TlsBootstrap*` settings via the `user_data` module. |
| `ca_certificate`            | A PEM formatted certificate of a custom Certificate Authority (CA) public certificate found in the Azure Key Vault | **Optional** <br>If TLS certificates in the deployment are signed by an unknown CA then this argument is required to enable end-to-end TLS. [Reference](https://docs.microsoft.com/en-us/azure/application-gateway/ssl-overview)                                                                                                                                                                                       |

### Connecting to the TFE Server Instance

[Azure Bastion](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview) is used in this module to connect to the TFE instance. Additional information on connecting to a Linux instance using SSH through Azure Bastion is available [here](https://docs.microsoft.com/en-us/azure/bastion/bastion-connect-vm-ssh).

1. Follow the steps in the [Deployment](#deployment) section
2. Copy the `instance_user_name` and `instance_private_key` Terraform outputs
3. Open the Azure portal
4. Navigate to the virtual machine instance
5. Click `connect` -> `bastion` -> `use bastion`
6. Enter the `instance_user_name` for `username`
7. Select `SSH Private Key` as the authentication type
8. Enter the `instance_private_key` for `ssh private key`
9. Click `connect`

### Connecting to the TFE Console

The TFE Console is only available in a standalone environment (vm_node_count == 1).

1. Follow the steps in the [Deployment](#deployment) section
2. Navigate to the URL supplied via `tfe_console_url` Terraform output
3. Copy the `tfe_console_password` Terraform output
4. Enter the console password
5. Click `Unlock`

### Connecting to the TFE Application

1. Follow the steps in the [Deployment](#deployment) section
2. Navigate to the URL supplied via `login_url` Terraform output (it may take several minutes for this to be available after initial deployment - you may monitor the progress of cloud init if desired on one of the instances)
3. Enter a `username`, `email`, and `password` for the initial user
4. Click `Create an account`
5. After the initial user is created you may access the TFE Application normally using the URL supplied via `tfe_application_url` Terraform output

## License

This code is released under the Mozilla Public License 2.0. Please see [LICENSE](https://github.com/hashicorp/terraform-azurerm-terraform-enterprise/blob/main/LICENSE)
for more details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 2.79 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 2.79 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ./modules/bastion | n/a |
| <a name="module_database"></a> [database](#module\_database) | ./modules/database | n/a |
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | ./modules/load_balancer | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |
| <a name="module_object_storage"></a> [object\_storage](#module\_object\_storage) | ./modules/object_storage | n/a |
| <a name="module_private_endpoints"></a> [private\_endpoints](#module\_private\_endpoints) | ./modules/private_endpoints | n/a |
| <a name="module_redis"></a> [redis](#module\_redis) | ./modules/redis | n/a |
| <a name="module_resource_groups"></a> [resource\_groups](#module\_resource\_groups) | ./modules/resource_groups | n/a |
| <a name="module_user_data"></a> [user\_data](#module\_user\_data) | ./modules/user_data | n/a |
| <a name="module_vm"></a> [vm](#module\_vm) | ./modules/vm | n/a |

## Resources

| Name | Type |
|------|------|
| [tls_private_key.tfe_ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_storage_account.tfe_redis_existing_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_blob_public_access"></a> [allow\_blob\_public\_access](#input\_allow\_blob\_public\_access) | 'Allow public access to the Storage account | `bool` | `false` | no |
| <a name="input_ca_certificate_secret"></a> [ca\_certificate\_secret](#input\_ca\_certificate\_secret) | A Key Vault secret which contains the Base64 encoded version of a PEM encoded public certificate of a<br>certificate authority (CA) to be trusted by the Virtual Machine Scale Set and the Application Gateway. This argument<br>is only required if TLS certificates in the deployment are not issued by a well-known CA. | <pre>object({<br>    id           = string<br>    key_vault_id = string<br>    name         = string<br>    value        = string<br>  })</pre> | `null` | no |
| <a name="input_create_bastion"></a> [create\_bastion](#input\_create\_bastion) | If true, will create Azure Bastion PaaS and required resources https://azure.microsoft.com/en-us/services/azure-bastion/ | `bool` | `true` | no |
| <a name="input_database_flexible_server"></a> [database\_flexible\_server](#input\_database\_flexible\_server) | Type of Postgres database resource, `azurerm_postgresql_flexible_server` or `azurerm_postgresql_server` | `bool` | `true` | no |
| <a name="input_database_machine_type"></a> [database\_machine\_type](#input\_database\_machine\_type) | Postgres sku short name: tier + family + cores | `string` | `"GP_Standard_D4s_v3"` | no |
| <a name="input_database_size_mb"></a> [database\_size\_mb](#input\_database\_size\_mb) | Postgres storage size in MB | `number` | `32768` | no |
| <a name="input_database_user"></a> [database\_user](#input\_database\_user) | Postgres username | `string` | `"tfeuser"` | no |
| <a name="input_database_version"></a> [database\_version](#input\_database\_version) | Postgres version | `number` | `12` | no |
| <a name="input_dedicated_subnets"></a> [dedicated\_subnets](#input\_dedicated\_subnets) | (Optional) Share subnet with application or having dedicated subnets for the storage and database | `bool` | `false` | no |
| <a name="input_default_action_ip_rules"></a> [default\_action\_ip\_rules](#input\_default\_action\_ip\_rules) | The IP rules for the Storage account default action | `list(string)` | `[]` | no |
| <a name="input_default_action_subnet_ids"></a> [default\_action\_subnet\_ids](#input\_default\_action\_subnet\_ids) | The Subnet Ids for the Storage account default action | `list(string)` | `[]` | no |
| <a name="input_dns_create_record"></a> [dns\_create\_record](#input\_dns\_create\_record) | If true, will create a DNS record. If false, no record will be created and IP of load balancer will instead be output. | `bool` | `true` | no |
| <a name="input_dns_external_fqdn"></a> [dns\_external\_fqdn](#input\_dns\_external\_fqdn) | External DNS FQDN should be supplied if dns\_create\_record is false | `string` | `null` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | (Required) Domain to create Terraform Enterprise subdomain within | `string` | `null` | no |
| <a name="input_friendly_name_prefix"></a> [friendly\_name\_prefix](#input\_friendly\_name\_prefix) | (Required) Name prefix used for resources | `string` | n/a | yes |
| <a name="input_load_balancer_certificate"></a> [load\_balancer\_certificate](#input\_load\_balancer\_certificate) | A Key Vault Certificate to be attached to the Application Gateway. | <pre>object({<br>    key_vault_id = string<br>    name         = string<br>    secret_id    = string<br>  })</pre> | `null` | no |
| <a name="input_load_balancer_public"></a> [load\_balancer\_public](#input\_load\_balancer\_public) | Load balancer will use public IP if true | `bool` | `true` | no |
| <a name="input_load_balancer_sku_name"></a> [load\_balancer\_sku\_name](#input\_load\_balancer\_sku\_name) | The Name of the SKU to use for Application Gateway, Standard\_v2 or WAF\_v2 accepted | `string` | `"Standard_v2"` | no |
| <a name="input_load_balancer_sku_tier"></a> [load\_balancer\_sku\_tier](#input\_load\_balancer\_sku\_tier) | The Tier of the SKU to use for Application Gateway, Standard\_v2 or WAF\_v2 accepted | `string` | `"Standard_v2"` | no |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | Expected value of 'application\_gateway' or 'load\_balancer' | `string` | `"application_gateway"` | no |
| <a name="input_load_balancer_waf_file_upload_limit_mb"></a> [load\_balancer\_waf\_file\_upload\_limit\_mb](#input\_load\_balancer\_waf\_file\_upload\_limit\_mb) | The File Upload Limit in MB. Accepted values are in the range 1MB to 750MB for the WAF\_v2 SKU, and 1MB to 500MB for all other SKUs. Defaults to 100MB. | `number` | `100` | no |
| <a name="input_load_balancer_waf_firewall_mode"></a> [load\_balancer\_waf\_firewall\_mode](#input\_load\_balancer\_waf\_firewall\_mode) | The Web Application Firewall mode (Detection or Prevention) | `string` | `"Prevention"` | no |
| <a name="input_load_balancer_waf_max_request_body_size_kb"></a> [load\_balancer\_waf\_max\_request\_body\_size\_kb](#input\_load\_balancer\_waf\_max\_request\_body\_size\_kb) | The Maximum Request Body Size in KB. Accepted values are in the range 1KB to 128KB. Defaults to 128KB. | `number` | `128` | no |
| <a name="input_load_balancer_waf_rule_set_version"></a> [load\_balancer\_waf\_rule\_set\_version](#input\_load\_balancer\_waf\_rule\_set\_version) | The Version of the Rule Set used for this Web Application Firewall. Possible values are 2.2.9, 3.0, and 3.1. | `string` | `"3.1"` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure location name e.g. East US | `string` | `"East US"` | no |
| <a name="input_network_allow_range"></a> [network\_allow\_range](#input\_network\_allow\_range) | (Optional) Network range to allow access to TFE | `string` | `"*"` | no |
| <a name="input_network_bastion_subnet_cidr"></a> [network\_bastion\_subnet\_cidr](#input\_network\_bastion\_subnet\_cidr) | (Optional) Subnet CIDR range for Bastion | `string` | `"10.0.16.0/20"` | no |
| <a name="input_network_bastion_subnet_id"></a> [network\_bastion\_subnet\_id](#input\_network\_bastion\_subnet\_id) | (Optional) Existing network Bastion subnet ID | `string` | `null` | no |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | (Optional) CIDR range for network | `string` | `"10.0.0.0/16"` | no |
| <a name="input_network_database_private_dns_zone_id"></a> [network\_database\_private\_dns\_zone\_id](#input\_network\_database\_private\_dns\_zone\_id) | The identity of an existing private DNS zone for the database. | `string` | `null` | no |
| <a name="input_network_database_subnet_cidr"></a> [network\_database\_subnet\_cidr](#input\_network\_database\_subnet\_cidr) | The CIDR range of the database subnetwork. | `string` | `"10.0.64.0/20"` | no |
| <a name="input_network_database_subnet_id"></a> [network\_database\_subnet\_id](#input\_network\_database\_subnet\_id) | The identity of an existing database subnetwork. | `string` | `null` | no |
| <a name="input_network_frontend_subnet_cidr"></a> [network\_frontend\_subnet\_cidr](#input\_network\_frontend\_subnet\_cidr) | (Optional) Subnet CIDR range for frontend | `string` | `"10.0.0.0/20"` | no |
| <a name="input_network_frontend_subnet_id"></a> [network\_frontend\_subnet\_id](#input\_network\_frontend\_subnet\_id) | (Optional) Existing network frontend subnet ID | `string` | `null` | no |
| <a name="input_network_private_subnet_cidr"></a> [network\_private\_subnet\_cidr](#input\_network\_private\_subnet\_cidr) | (Optional) Subnet CIDR range for TFE | `string` | `"10.0.32.0/20"` | no |
| <a name="input_network_private_subnet_id"></a> [network\_private\_subnet\_id](#input\_network\_private\_subnet\_id) | (Optional) Existing network private subnet ID | `string` | `null` | no |
| <a name="input_network_redis_subnet_cidr"></a> [network\_redis\_subnet\_cidr](#input\_network\_redis\_subnet\_cidr) | (Optional) Subnet CIDR range for Redis | `string` | `"10.0.48.0/20"` | no |
| <a name="input_network_redis_subnet_id"></a> [network\_redis\_subnet\_id](#input\_network\_redis\_subnet\_id) | (Optional) Existing network Redis subnet ID | `string` | `null` | no |
| <a name="input_network_rules_default_action"></a> [network\_rules\_default\_action](#input\_network\_rules\_default\_action) | Storage account default access rule, which can be 'Allow' or 'Deny' | `string` | n/a | yes |
| <a name="input_network_storage_subnet_cidr"></a> [network\_storage\_subnet\_cidr](#input\_network\_storage\_subnet\_cidr) | The CIDR range of the storage subnetwork. | `string` | `"10.0.80.0/20"` | no |
| <a name="input_network_storage_subnet_id"></a> [network\_storage\_subnet\_id](#input\_network\_storage\_subnet\_id) | The identity of an existing storage account subnetwork. | `string` | `null` | no |
| <a name="input_private_link_enforced"></a> [private\_link\_enforced](#input\_private\_link\_enforced) | (Optional) Enforce private link policies | `bool` | `false` | no |
| <a name="input_proxy_ip"></a> [proxy\_ip](#input\_proxy\_ip) | IP Address of the proxy server | `string` | `null` | no |
| <a name="input_proxy_port"></a> [proxy\_port](#input\_proxy\_port) | Port that the proxy server will use | `string` | `null` | no |
| <a name="input_redis_enable_authentication"></a> [redis\_enable\_authentication](#input\_redis\_enable\_authentication) | If set to false, the Redis instance will be accessible without authentication. enable\_authentication can only be set to false if a subnet\_id is specified; and only works if there aren't existing instances within the subnet with enable\_authentication set to true. | `bool` | `true` | no |
| <a name="input_redis_enable_non_ssl_port"></a> [redis\_enable\_non\_ssl\_port](#input\_redis\_enable\_non\_ssl\_port) | Enable the non-SSL port (6379) | `bool` | `false` | no |
| <a name="input_redis_family"></a> [redis\_family](#input\_redis\_family) | (Required) The SKU family/pricing group to use. Valid values are C (for Basic/Standard SKU family) and P (for Premium) | `string` | `"P"` | no |
| <a name="input_redis_rdb_backup_enabled"></a> [redis\_rdb\_backup\_enabled](#input\_redis\_rdb\_backup\_enabled) | (Optional) Is Backup Enabled? Only supported on Premium SKU's. If rdb\_backup\_enabled is true and redis\_rdb\_storage\_connection\_string is null, a new, Premium storage account will be created. | `bool` | `false` | no |
| <a name="input_redis_rdb_backup_frequency"></a> [redis\_rdb\_backup\_frequency](#input\_redis\_rdb\_backup\_frequency) | (Optional) The Backup Frequency in Minutes. Only supported on Premium SKU's. Possible values are: 15, 30, 60, 360, 720 and 1440. | `number` | `null` | no |
| <a name="input_redis_rdb_backup_max_snapshot_count"></a> [redis\_rdb\_backup\_max\_snapshot\_count](#input\_redis\_rdb\_backup\_max\_snapshot\_count) | (Optional) The maximum number of snapshots to create as a backup. Only supported for Premium SKU's. | `number` | `null` | no |
| <a name="input_redis_rdb_existing_storage_account"></a> [redis\_rdb\_existing\_storage\_account](#input\_redis\_rdb\_existing\_storage\_account) | (Optional) Name of an existing Premium Storage Account for data encryption at rest. If value is null, a new, Premium storage account will be created. | `string` | `null` | no |
| <a name="input_redis_rdb_existing_storage_account_rg"></a> [redis\_rdb\_existing\_storage\_account\_rg](#input\_redis\_rdb\_existing\_storage\_account\_rg) | (Optional) Name of the resource group that contains the existing Premium Storage Account for data encryption at rest. | `string` | `null` | no |
| <a name="input_redis_size"></a> [redis\_size](#input\_redis\_size) | The size of the Redis cache to deploy. Valid values for a SKU family of C (Basic/Standard) are 0, 1, 2, 3, 4, 5, 6, and for P (Premium) family are 1, 2, 3, 4. | `string` | `"3"` | no |
| <a name="input_redis_sku_name"></a> [redis\_sku\_name](#input\_redis\_sku\_name) | (Required) The SKU of Redis to use. Possible values are Basic, Standard and Premium. | `string` | `"Premium"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Azure resource group name | `string` | `null` | no |
| <a name="input_resource_group_name_dns"></a> [resource\_group\_name\_dns](#input\_resource\_group\_name\_dns) | Name of resource group which contains desired DNS zone | `string` | `null` | no |
| <a name="input_storage_account_container_name"></a> [storage\_account\_container\_name](#input\_storage\_account\_container\_name) | Storage account container name | `string` | `null` | no |
| <a name="input_storage_account_key"></a> [storage\_account\_key](#input\_storage\_account\_key) | Storage account key | `string` | `null` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Storage account name | `string` | `null` | no |
| <a name="input_storage_account_primary_blob_connection_string"></a> [storage\_account\_primary\_blob\_connection\_string](#input\_storage\_account\_primary\_blob\_connection\_string) | Storage account primary blob endpoint | `string` | `null` | no |
| <a name="input_storage_account_replication_type"></a> [storage\_account\_replication\_type](#input\_storage\_account\_replication\_type) | Storage account type LRS, GRS, RAGRS, ZRS | `string` | `"ZRS"` | no |
| <a name="input_storage_account_tier"></a> [storage\_account\_tier](#input\_storage\_account\_tier) | Storage account tier Standard or Premium | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags for resource | `map(string)` | `{}` | no |
| <a name="input_tfe_license_secret"></a> [tfe\_license\_secret](#input\_tfe\_license\_secret) | The Key Vault secret under which the Base64 encoded TFE license is stored. | <pre>object({<br>    id = string<br>  })</pre> | n/a | yes |
| <a name="input_tfe_subdomain"></a> [tfe\_subdomain](#input\_tfe\_subdomain) | Subdomain for TFE | `string` | `null` | no |
| <a name="input_user_data_iact_subnet_list"></a> [user\_data\_iact\_subnet\_list](#input\_user\_data\_iact\_subnet\_list) | A list of IP address ranges which will be authorized to access the IACT. The ranges must be expressed<br>in CIDR notation. | `list(string)` | `[]` | no |
| <a name="input_user_data_installation_type"></a> [user\_data\_installation\_type](#input\_user\_data\_installation\_type) | Installation type for Terraform Enterprise | `string` | `"production"` | no |
| <a name="input_user_data_redis_use_tls"></a> [user\_data\_redis\_use\_tls](#input\_user\_data\_redis\_use\_tls) | Boolean to determine if TLS should be used | `bool` | `true` | no |
| <a name="input_user_data_release_sequence"></a> [user\_data\_release\_sequence](#input\_user\_data\_release\_sequence) | Terraform Enterprise release sequence | `string` | `null` | no |
| <a name="input_user_data_trusted_proxies"></a> [user\_data\_trusted\_proxies](#input\_user\_data\_trusted\_proxies) | A list of IP address ranges which will be considered safe to ignore when evaluating the IP addresses of requests like<br>those made to the IACT endpoint. | `list(string)` | `[]` | no |
| <a name="input_vm_certificate_secret"></a> [vm\_certificate\_secret](#input\_vm\_certificate\_secret) | A Key Vault secret which contains the Base64 encoded version of a PEM encoded public certificate for the Virtual<br>Machine Scale Set. | <pre>object({<br>    key_vault_id = string<br>    id           = string<br>  })</pre> | `null` | no |
| <a name="input_vm_image_id"></a> [vm\_image\_id](#input\_vm\_image\_id) | Virtual machine image id - may be 'ubuntu' (default), 'rhel', or custom image resource id | `string` | `"ubuntu"` | no |
| <a name="input_vm_key_secret"></a> [vm\_key\_secret](#input\_vm\_key\_secret) | A Key Vault secret which contains the Base64 encoded version of a PEM encoded private key for the Virtual Machine<br>Scale Set. | <pre>object({<br>    key_vault_id = string<br>    id           = string<br>  })</pre> | `null` | no |
| <a name="input_vm_node_count"></a> [vm\_node\_count](#input\_vm\_node\_count) | The number of instances to create for TFE environment | `number` | `2` | no |
| <a name="input_vm_os_disk_disk_size_gb"></a> [vm\_os\_disk\_disk\_size\_gb](#input\_vm\_os\_disk\_disk\_size\_gb) | The size of the Data Disk which should be created | `number` | `100` | no |
| <a name="input_vm_public_key"></a> [vm\_public\_key](#input\_vm\_public\_key) | Virtual machine public key for authentication (2048-bit ssh-rsa) | `string` | `null` | no |
| <a name="input_vm_sku"></a> [vm\_sku](#input\_vm\_sku) | Azure virtual machine sku | `string` | `"Standard_D4_v3"` | no |
| <a name="input_vm_user"></a> [vm\_user](#input\_vm\_user) | Virtual machine user name | `string` | `"tfeuser"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Azure zones to use for applicable resources | `list(string)` | <pre>[<br>  "1",<br>  "2",<br>  "3"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_host_dns_name"></a> [bastion\_host\_dns\_name](#output\_bastion\_host\_dns\_name) | The DNS name of the bastion host vm |
| <a name="output_bastion_host_id"></a> [bastion\_host\_id](#output\_bastion\_host\_id) | The resource ID of the Azure bastion host |
| <a name="output_database"></a> [database](#output\_database) | The TFE PostgreSQL database. |
| <a name="output_instance_private_key"></a> [instance\_private\_key](#output\_instance\_private\_key) | The SSH private key to the TFE instance(s) |
| <a name="output_instance_user_name"></a> [instance\_user\_name](#output\_instance\_user\_name) | The admin user on the TFE instance(s) |
| <a name="output_load_balancer_backend_id"></a> [load\_balancer\_backend\_id](#output\_load\_balancer\_backend\_id) | The backend address pool ID |
| <a name="output_load_balancer_ip"></a> [load\_balancer\_ip](#output\_load\_balancer\_ip) | The IP address of the load balancer |
| <a name="output_login_url"></a> [login\_url](#output\_login\_url) | Login URL to setup the TFE instance once it is initialized |
| <a name="output_network"></a> [network](#output\_network) | The virtual network used for all resources |
| <a name="output_redis_hostname"></a> [redis\_hostname](#output\_redis\_hostname) | The Hostname of the Redis Instance |
| <a name="output_redis_pass"></a> [redis\_pass](#output\_redis\_pass) | The Primary Access Key for the Redis Instance |
| <a name="output_redis_ssl_port"></a> [redis\_ssl\_port](#output\_redis\_ssl\_port) | The SSL Port of the Redis Instance |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group into which to provision all resources |
| <a name="output_storage_account_container_name"></a> [storage\_account\_container\_name](#output\_storage\_account\_container\_name) | The name of the container used by TFE |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account used by TFE |
| <a name="output_tfe_application_url"></a> [tfe\_application\_url](#output\_tfe\_application\_url) | Terraform Enterprise Application URL |
| <a name="output_tfe_console_password"></a> [tfe\_console\_password](#output\_tfe\_console\_password) | The password for the TFE console |
| <a name="output_tfe_console_url"></a> [tfe\_console\_url](#output\_tfe\_console\_url) | Terraform Enterprise Console URL |
| <a name="output_tfe_userdata_base64_encoded"></a> [tfe\_userdata\_base64\_encoded](#output\_tfe\_userdata\_base64\_encoded) | The Base64 encoded User Data script built from modules/user\_data/templates/tfe.sh.tpl |
<!-- END_TF_DOCS -->