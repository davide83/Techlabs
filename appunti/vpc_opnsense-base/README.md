(wip) Techlabs' VPC Openstack - Opnsense
===

Importeremo un'immagine personalizzata di un'_Appliance_ virtuale tipo **opnsense**, disabiliteremo l'openstack _security port_ per le reti private e saremo pronti per mettere in opera la nostra piattaforma di sicurezza preferita operandola in autonomia. Illustreremo entrambi gli scenari da riga di comando e da interfaccia grafica.

# Requisiti
[ref. KB0065106](https://help.ovhcloud.com/csm/en-public-cloud-network-stormshield-vrack?id=kb_article_view&sysparm_article=KB0065106)
- verifica prerequisiti `ls Teclabs/appunti/vpc_openstack-base`
- Additional IP (regional IPv4 Block) associato alla vRack (**vlan 0**)
- - `GET /vrack/{serviceName}/ip/{ip}/availableZone`
- - ![alt text](images/pn-VPC_opnsense-PAR-RED-0_ip_availableZone.png)
- - It requires an active RIPE/ARIN organization to be assigned
- cambia directory `cd Teclabs/appunti/vpc_opnsense-base`

## Deploy Nets

Definiamo la segmentazione regionale via reti private **vrack** con segmentazione o `vlan id`

### Regional Nets

Definiamo una segmentazione per pseudo_port/vlan_id, per esempio a _**Paris** - EU-WEST-PAR **3AZ**_, come segue

| segment_contex | --disable-port-security | segment_id | segment_name | pseudo_port |
| ----- | ----- | ----- | ----- | ----- |
| LAN | SI | 2042 | GREEN | lan/management |
| WAN | SI | 0 _(untagged)_ | RED | wan |
| OPT-1 (DMZ) | SI | 2044 | ORANGE | dmz |
| OPT-2 (VPN) | SI | 2045 | BLUE | vpn |
| OPT-3 (CARP) | SI | 2046 | PINK | transit/carp/vrrp |

> Public Cloud Local Zone deployment doesn't support importing custom images yet! ETA on GA to be confirmed!

#### Reti GREEN/RED (LAN/WAN)

Riversiamo il contenuto del file ovhrc come variabili d'ambiente se non già fatto

```bash
(techlab) dletizia@ovh vpc_opnsense-base % . utils/ovhrc
```

mettiano in opera le reti per le regioni d'interesse

```bash
(techlab) dletizia@ovh vpc_opnsense-base % ./scripts/oscVPC-deployAllNetworks.sh
DEPLOYING VPC opnsenseNETWORKs IN PAR ...
DEPLOYING VPC opnsense GREEN segment as 2042...
+---------------------------+---------------------------------------------------------------------------+
| Field                     | Value                                                                     |
+---------------------------+---------------------------------------------------------------------------+
| admin_state_up            | UP                                                                        |
| availability_zone_hints   | eu-west-par-a, eu-west-par-b, eu-west-par-c                               |
| availability_zones        |                                                                           |
| created_at                | 2025-04-19T13:44:33Z                                                      |
| description               | Techlabs' VPC_opnsense-base (vlan_id: 2042 / GREEN) privateNetwork in PAR |
| dns_domain                | None                                                                      |
| id                        | 8e310f1f-7db8-4730-82f4-c468006f589e                                      |
| ipv4_address_scope        | None                                                                      |
| ipv6_address_scope        | None                                                                      |
| is_default                | False                                                                     |
| is_vlan_transparent       | None                                                                      |
| l2_adjacency              | True                                                                      |
| mtu                       | 1500                                                                      |
| name                      | pn-VPC_opnsense-PAR-GREEN-2042                                            |
| port_security_enabled     | False                                                                     |
| project_id                | dfee9c2cdc20401fba5b26c024933164                                          |
| provider:network_type     | vrack                                                                     |
| provider:physical_network | None                                                                      |
| provider:segmentation_id  | 2042                                                                      |
| qos_policy_id             | None                                                                      |
| revision_number           | 1                                                                         |
| router:external           | Internal                                                                  |
| segments                  | None                                                                      |
| shared                    | False                                                                     |
| status                    | ACTIVE                                                                    |
| subnets                   |                                                                           |
| tags                      |                                                                           |
| updated_at                | 2025-04-19T13:44:33Z                                                      |
+---------------------------+---------------------------------------------------------------------------+
+----------------------+--------------------------------------------------------------------------------------------------+
| Field                | Value                                                                                            |
+----------------------+--------------------------------------------------------------------------------------------------+
| allocation_pools     | 192.168.42.128-192.168.42.254                                                                    |
| cidr                 | 192.168.42.0/24                                                                                  |
| created_at           | 2025-04-19T13:44:35Z                                                                             |
| description          | Techlabs' VPC_opnsense-base (vlan_id: 2042 / GREEN) Private Subnet 192.168.42.0/24 in PAR region |
| dns_nameservers      |                                                                                                  |
| dns_publish_fixed_ip | None                                                                                             |
| enable_dhcp          | False                                                                                            |
| gateway_ip           | 192.168.42.1                                                                                     |
| host_routes          |                                                                                                  |
| id                   | b362dcf1-79e0-4300-b2be-28d1bc2ae4a9                                                             |
| ip_version           | 4                                                                                                |
| ipv6_address_mode    | None                                                                                             |
| ipv6_ra_mode         | None                                                                                             |
| name                 | pnSbnt-VPC_opnsense-PAR-GREEN-2042-192-168-42-0_24                                               |
| network_id           | 8e310f1f-7db8-4730-82f4-c468006f589e                                                             |
| project_id           | dfee9c2cdc20401fba5b26c024933164                                                                 |
| revision_number      | 0                                                                                                |
| segment_id           | None                                                                                             |
| service_types        |                                                                                                  |
| subnetpool_id        | None                                                                                             |
| tags                 |                                                                                                  |
| updated_at           | 2025-04-19T13:44:35Z                                                                             |
+----------------------+--------------------------------------------------------------------------------------------------+
\!/ CHECK IF segment GREEN WAS DEPLOYED IN PAR as 2042 SUCCESSFUL \!/
DEPLOYING VPC opnsense RED segment as 0...
+---------------------------+----------------------------------------------------------------------+
| Field                     | Value                                                                |
+---------------------------+----------------------------------------------------------------------+
| admin_state_up            | UP                                                                   |
| availability_zone_hints   | eu-west-par-a, eu-west-par-b, eu-west-par-c                          |
| availability_zones        |                                                                      |
| created_at                | 2025-04-19T13:44:37Z                                                 |
| description               | Techlabs' VPC_opnsense-base (vlan_id: 0 / RED) privateNetwork in PAR |
| dns_domain                | None                                                                 |
| id                        | 238ecd00-c4f7-417b-805d-f80139e1b185                                 |
| ipv4_address_scope        | None                                                                 |
| ipv6_address_scope        | None                                                                 |
| is_default                | False                                                                |
| is_vlan_transparent       | None                                                                 |
| l2_adjacency              | True                                                                 |
| mtu                       | 1500                                                                 |
| name                      | pn-VPC_opnsense-PAR-RED-0                                            |
| port_security_enabled     | False                                                                |
| project_id                | dfee9c2cdc20401fba5b26c024933164                                     |
| provider:network_type     | vrack                                                                |
| provider:physical_network | None                                                                 |
| provider:segmentation_id  | 0                                                                    |
| qos_policy_id             | None                                                                 |
| revision_number           | 1                                                                    |
| router:external           | Internal                                                             |
| segments                  | None                                                                 |
| shared                    | False                                                                |
| status                    | ACTIVE                                                               |
| subnets                   |                                                                      |
| tags                      |                                                                      |
| updated_at                | 2025-04-19T13:44:37Z                                                 |
+---------------------------+----------------------------------------------------------------------+
+----------------------+---------------------------------------------------------------------------------------------+
| Field                | Value                                                                                       |
+----------------------+---------------------------------------------------------------------------------------------+
| allocation_pools     | 57.130.12.89-57.130.12.89                                                                   |
| cidr                 | 57.130.12.88/30                                                                             |
| created_at           | 2025-04-19T13:44:39Z                                                                        |
| description          | Techlabs' VPC_opnsense-base (vlan_id: 0 / RED) Private Subnet 57.130.12.88/30 in PAR region |
| dns_nameservers      |                                                                                             |
| dns_publish_fixed_ip | None                                                                                        |
| enable_dhcp          | False                                                                                       |
| gateway_ip           | 57.130.12.90                                                                                |
| host_routes          |                                                                                             |
| id                   | 8ff5af02-3070-4888-a280-76b3f8e5321e                                                        |
| ip_version           | 4                                                                                           |
| ipv6_address_mode    | None                                                                                        |
| ipv6_ra_mode         | None                                                                                        |
| name                 | pnSbnt-VPC_opnsense-PAR-RED-0-57-130-12-88_30                                               |
| network_id           | 238ecd00-c4f7-417b-805d-f80139e1b185                                                        |
| project_id           | dfee9c2cdc20401fba5b26c024933164                                                            |
| revision_number      | 0                                                                                           |
| segment_id           | None                                                                                        |
| service_types        |                                                                                             |
| subnetpool_id        | None                                                                                        |
| tags                 |                                                                                             |
| updated_at           | 2025-04-19T13:44:39Z                                                                        |
+----------------------+---------------------------------------------------------------------------------------------+
\!/ CHECK IF segment RED WAS DEPLOYED IN PAR as 0 SUCCESSFUL \!/
DEPLOYING VPC opnsense ORANGE segment as 2044...
+---------------------------+----------------------------------------------------------------------------+
| Field                     | Value                                                                      |
+---------------------------+----------------------------------------------------------------------------+
| admin_state_up            | UP                                                                         |
| availability_zone_hints   | eu-west-par-a, eu-west-par-b, eu-west-par-c                                |
| availability_zones        |                                                                            |
| created_at                | 2025-04-19T13:44:41Z                                                       |
| description               | Techlabs' VPC_opnsense-base (vlan_id: 2044 / ORANGE) privateNetwork in PAR |
| dns_domain                | None                                                                       |
| id                        | ca9267e1-b9f9-4bf4-939f-5c614bb3fa1f                                       |
| ipv4_address_scope        | None                                                                       |
| ipv6_address_scope        | None                                                                       |
| is_default                | False                                                                      |
| is_vlan_transparent       | None                                                                       |
| l2_adjacency              | True                                                                       |
| mtu                       | 1500                                                                       |
| name                      | pn-VPC_opnsense-PAR-ORANGE-2044                                            |
| port_security_enabled     | False                                                                      |
| project_id                | dfee9c2cdc20401fba5b26c024933164                                           |
| provider:network_type     | vrack                                                                      |
| provider:physical_network | None                                                                       |
| provider:segmentation_id  | 2044                                                                       |
| qos_policy_id             | None                                                                       |
| revision_number           | 1                                                                          |
| router:external           | Internal                                                                   |
| segments                  | None                                                                       |
| shared                    | False                                                                      |
| status                    | ACTIVE                                                                     |
| subnets                   |                                                                            |
| tags                      |                                                                            |
| updated_at                | 2025-04-19T13:44:41Z                                                       |
+---------------------------+----------------------------------------------------------------------------+
+----------------------+---------------------------------------------------------------------------------------------------+
| Field                | Value                                                                                             |
+----------------------+---------------------------------------------------------------------------------------------------+
| allocation_pools     | 192.168.44.128-192.168.44.254                                                                     |
| cidr                 | 192.168.44.0/24                                                                                   |
| created_at           | 2025-04-19T13:44:42Z                                                                              |
| description          | Techlabs' VPC_opnsense-base (vlan_id: 2044 / ORANGE) Private Subnet 192.168.44.0/24 in PAR region |
| dns_nameservers      |                                                                                                   |
| dns_publish_fixed_ip | None                                                                                              |
| enable_dhcp          | True                                                                                              |
| gateway_ip           | 192.168.44.1                                                                                      |
| host_routes          |                                                                                                   |
| id                   | dbcc067e-b0f2-4a89-9eaa-165d310e7f1d                                                              |
| ip_version           | 4                                                                                                 |
| ipv6_address_mode    | None                                                                                              |
| ipv6_ra_mode         | None                                                                                              |
| name                 | pnSbnt-VPC_opnsense-PAR-ORANGE-2044-192-168-44-0_24                                               |
| network_id           | ca9267e1-b9f9-4bf4-939f-5c614bb3fa1f                                                              |
| project_id           | dfee9c2cdc20401fba5b26c024933164                                                                  |
| revision_number      | 0                                                                                                 |
| segment_id           | None                                                                                              |
| service_types        |                                                                                                   |
| subnetpool_id        | None                                                                                              |
| tags                 |                                                                                                   |
| updated_at           | 2025-04-19T13:44:42Z                                                                              |
+----------------------+---------------------------------------------------------------------------------------------------+
\!/ CHECK IF segment ORANGE WAS DEPLOYED IN PAR as 2044 SUCCESSFUL \!/
DEPLOYING VPC opnsense BLUE segment as 2045...
+---------------------------+--------------------------------------------------------------------------+
| Field                     | Value                                                                    |
+---------------------------+--------------------------------------------------------------------------+
| admin_state_up            | UP                                                                       |
| availability_zone_hints   | eu-west-par-a, eu-west-par-b, eu-west-par-c                              |
| availability_zones        |                                                                          |
| created_at                | 2025-04-19T13:44:44Z                                                     |
| description               | Techlabs' VPC_opnsense-base (vlan_id: 2045 / BLUE) privateNetwork in PAR |
| dns_domain                | None                                                                     |
| id                        | 0b946a52-ef19-43d8-b3c3-812d9de2714e                                     |
| ipv4_address_scope        | None                                                                     |
| ipv6_address_scope        | None                                                                     |
| is_default                | False                                                                    |
| is_vlan_transparent       | None                                                                     |
| l2_adjacency              | True                                                                     |
| mtu                       | 1500                                                                     |
| name                      | pn-VPC_opnsense-PAR-BLUE-2045                                            |
| port_security_enabled     | False                                                                    |
| project_id                | dfee9c2cdc20401fba5b26c024933164                                         |
| provider:network_type     | vrack                                                                    |
| provider:physical_network | None                                                                     |
| provider:segmentation_id  | 2045                                                                     |
| qos_policy_id             | None                                                                     |
| revision_number           | 1                                                                        |
| router:external           | Internal                                                                 |
| segments                  | None                                                                     |
| shared                    | False                                                                    |
| status                    | ACTIVE                                                                   |
| subnets                   |                                                                          |
| tags                      |                                                                          |
| updated_at                | 2025-04-19T13:44:44Z                                                     |
+---------------------------+--------------------------------------------------------------------------+
+----------------------+-------------------------------------------------------------------------------------------------+
| Field                | Value                                                                                           |
+----------------------+-------------------------------------------------------------------------------------------------+
| allocation_pools     | 192.168.45.128-192.168.45.254                                                                   |
| cidr                 | 192.168.45.0/24                                                                                 |
| created_at           | 2025-04-19T13:44:46Z                                                                            |
| description          | Techlabs' VPC_opnsense-base (vlan_id: 2045 / BLUE) Private Subnet 192.168.45.0/24 in PAR region |
| dns_nameservers      |                                                                                                 |
| dns_publish_fixed_ip | None                                                                                            |
| enable_dhcp          | False                                                                                           |
| gateway_ip           | 192.168.45.1                                                                                    |
| host_routes          |                                                                                                 |
| id                   | 98b0ee11-750f-4ef2-94c8-b83c47ea121f                                                            |
| ip_version           | 4                                                                                               |
| ipv6_address_mode    | None                                                                                            |
| ipv6_ra_mode         | None                                                                                            |
| name                 | pnSbnt-VPC_opnsense-PAR-BLUE-2045-192-168-45-0_24                                               |
| network_id           | 0b946a52-ef19-43d8-b3c3-812d9de2714e                                                            |
| project_id           | dfee9c2cdc20401fba5b26c024933164                                                                |
| revision_number      | 0                                                                                               |
| segment_id           | None                                                                                            |
| service_types        |                                                                                                 |
| subnetpool_id        | None                                                                                            |
| tags                 |                                                                                                 |
| updated_at           | 2025-04-19T13:44:46Z                                                                            |
+----------------------+-------------------------------------------------------------------------------------------------+
\!/ CHECK IF segment BLUE WAS DEPLOYED IN PAR as 2045 SUCCESSFUL \!/
DEPLOYING VPC opnsense PINK segment as 2046...
+---------------------------+--------------------------------------------------------------------------+
| Field                     | Value                                                                    |
+---------------------------+--------------------------------------------------------------------------+
| admin_state_up            | UP                                                                       |
| availability_zone_hints   | eu-west-par-a, eu-west-par-b, eu-west-par-c                              |
| availability_zones        |                                                                          |
| created_at                | 2025-04-19T13:44:48Z                                                     |
| description               | Techlabs' VPC_opnsense-base (vlan_id: 2046 / PINK) privateNetwork in PAR |
| dns_domain                | None                                                                     |
| id                        | adb7b10d-2c62-4488-a544-529eebe255f6                                     |
| ipv4_address_scope        | None                                                                     |
| ipv6_address_scope        | None                                                                     |
| is_default                | False                                                                    |
| is_vlan_transparent       | None                                                                     |
| l2_adjacency              | True                                                                     |
| mtu                       | 1500                                                                     |
| name                      | pn-VPC_opnsense-PAR-PINK-2046                                            |
| port_security_enabled     | False                                                                    |
| project_id                | dfee9c2cdc20401fba5b26c024933164                                         |
| provider:network_type     | vrack                                                                    |
| provider:physical_network | None                                                                     |
| provider:segmentation_id  | 2046                                                                     |
| qos_policy_id             | None                                                                     |
| revision_number           | 1                                                                        |
| router:external           | Internal                                                                 |
| segments                  | None                                                                     |
| shared                    | False                                                                    |
| status                    | ACTIVE                                                                   |
| subnets                   |                                                                          |
| tags                      |                                                                          |
| updated_at                | 2025-04-19T13:44:48Z                                                     |
+---------------------------+--------------------------------------------------------------------------+
+----------------------+-------------------------------------------------------------------------------------------------+
| Field                | Value                                                                                           |
+----------------------+-------------------------------------------------------------------------------------------------+
| allocation_pools     | 192.168.46.128-192.168.46.254                                                                   |
| cidr                 | 192.168.46.0/24                                                                                 |
| created_at           | 2025-04-19T13:44:50Z                                                                            |
| description          | Techlabs' VPC_opnsense-base (vlan_id: 2046 / PINK) Private Subnet 192.168.46.0/24 in PAR region |
| dns_nameservers      |                                                                                                 |
| dns_publish_fixed_ip | None                                                                                            |
| enable_dhcp          | False                                                                                           |
| gateway_ip           | 192.168.46.1                                                                                    |
| host_routes          |                                                                                                 |
| id                   | 82e48719-b81f-4ef2-b61e-8adf4e86dc64                                                            |
| ip_version           | 4                                                                                               |
| ipv6_address_mode    | None                                                                                            |
| ipv6_ra_mode         | None                                                                                            |
| name                 | pnSbnt-VPC_opnsense-PAR-PINK-2046-192-168-46-0_24                                               |
| network_id           | adb7b10d-2c62-4488-a544-529eebe255f6                                                            |
| project_id           | dfee9c2cdc20401fba5b26c024933164                                                                |
| revision_number      | 0                                                                                               |
| segment_id           | None                                                                                            |
| service_types        |                                                                                                 |
| subnetpool_id        | None                                                                                            |
| tags                 |                                                                                                 |
| updated_at           | 2025-04-19T13:44:50Z                                                                            |
+----------------------+-------------------------------------------------------------------------------------------------+
\!/ CHECK IF segment PINK WAS DEPLOYED IN PAR as 2046 SUCCESSFUL \!/
\!/ CHECK IF VPC opnsenseNETWORKs WERE DEPLOYED IN PAR SUCCESSFUL \!/
```
VPC 198.168.0.0/16 , per esempio: 

> Parigi _(EU-WEST-PAR)_ come segue
>
> DEMO HERE only!

WAN IPs via vRack (RTvRack - **vlan 0**):
- Additiona IP `57.130.12.88/30`

~~~
57.130.12.88	57.130.12.89-57.130.12.90	57.130.12.91
~~~

| net_cidr | address_network | usable_host_range | address_gateway | address_broadcast |
| ----- | ----- | ----- | ----- | ----- |
| 57.130.12.88/30 | 57.130.12.88 | 57.130.12.89 | 57.130.12.90 | 57.130.12.91 |

Per ogni Blocco IPv4 `net_cidr` 3 indirizzi di rete sono riservati come `address_network`, gateway `address_gateway` e broadcast `address_broadcast`. Rimane un solo un indirizzo utilizzabile `57.130.12.89` e lo associeremo all'interfaccia di rete **RED** _WAN/vlan 0_

| vpc_region | vpc_net_name | vpc_net_id | os_net_name | vpc_subnet |
| ----- | ----- | ----- | ----- | ----- |
| PAR | GREEN | 2042 | pn-VPC_opnsense-GRA-GREEN-2042 | 192.168.42.0/24 |
| PAR | RED | 2043 | pn-VPC_opnsense-PAR-RED-2043 | 57.130.12.88/30 |
| PAR | ORANGE | 2044 | pn-VPC_opnsense-PAR-ORANGE-2044 | 192.168.44.0/24 |
| PAR | BLUE | 2045 | pn-VPC_opnsense-PAR-BLUE-2045 | 192.168.45.0/24 |
| PAR | PINK | 2046 | pn-VPC_opnsense-PAR-PINK-2046 | 192.168.46.0/29 |

![alt text](images/pn-VPC_opnsense-PAR-X-Y.png)

> Milano _(EU-SOUTH-MIL)_ come segue

| vpc_region | vpc_net_name | vpc_net_id | os_net_name | vpc_subnet |
| ----- | ----- | ----- | ----- | ----- |
| MIL | GREEN | 2052 | pn-VPC_opnsense-MIL-GREEN-2052 | 192.168.52.0/24 |
| MIL | RED | 2053 | pn-VPC_opnsense-MIL-RED-2053 | 192.168.53.0/24 |
| MIL | ORANGE | 2054 | pn-VPC_opnsense-MIL-ORANGE-2054 | 192.168.54.0/24 |
| MIL | BLUE | 2055 | pn-VPC_opnsense-MIL-BLUE-2055 | 192.168.55.0/24 |
| MIL | PINK | 2056 | pn-VPC_opnsense-MIL-PINK-2056 | 192.168.56.0/24 |

> Gravelines _(GRA11)_ come segue

| vpc_region | vpc_net_name | vpc_net_id | os_net_name | vpc_subnet |
| ----- | ----- | ----- | ----- | ----- |
| GRA | GREEN | 2062 | pn-VPC_opnsense-GRA-GREEN-2062 | 192.168.62.0/24 |
| GRA | RED | 2063 | pn-VPC_opnsense-GRA-RED-2063 | 192.168.63.0/24 |
| GRA | ORANGE | 2064 | pn-VPC_opnsense-GRA-ORANGE-2064 | 192.168.64.0/24 |
| GRA | BLUE | 2065 | pn-VPC_opnsense-GRA-BLUE-2065 | 192.168.65.0/24 |
| GRA | PINK | 2066 | pn-VPC_opnsense-GRA-PINK-2066 | 192.168.66.0/24 |

> Limburg _(DE1)_ come segue

| vpc_region | vpc_net_name | vpc_net_id | os_net_name | vpc_subnet |
| ----- | ----- | ----- | ----- | ----- |
| LIM | GREEN | 2072 | pn-VPC_opnsense-LIM-GREEN-2072 | 192.168.72.0/24 |
| LIM | RED | 2073 | pn-VPC_opnsense-LIM-RED-2073 | 192.168.73.0/24 |
| LIM | ORANGE | 2074 | pn-VPC_opnsense-GRA-ORANGE-2074 | 192.168.74.0/24 |
| LIM | BLUE | 2075 | pn-VPC_opnsense-GRA-BLUE-2075 | 192.168.75.0/24 |
| LIM | PINK | 2076 | pn-VPC_opnsense-GRA-PINK-2076 | 192.168.76.0/24 |

# VM Image via Openstack Client

> `OPN_RELEASE=25.1`

## GET VM IMAGE

[ref](https://github.com/maurice-w/opnsense-vm-images/releases)

Default settings are `OPN_VM_IMAGE_VERSION=25.1`, `OPN_VM_IMAGE_ARCH=amd64`, `OPN_VM_IMAGE_CONSOLE=efi`, `OPN_VM_IMAGE_DISK_FORMAT=qcow2`

```bash
(techlab) dletizia@ovh vpc_opnsense-base % ./scripts/oscVPC-getImage-opnsenseVM.sh
--2025-04-16 09:44:03--  https://github.com/maurice-w/opnsense-vm-images/releases/download/25.1/OPNsense-25.1-ufs-efi-vm-amd64.qcow2.bz2
Resolving github.com (github.com)... 140.82.121.3
Connecting to github.com (github.com)|140.82.121.3|:443... connected.
WARNING: cannot verify github.com's certificate, issued by ‘CN=Sectigo ECC Domain Validation Secure Server CA,O=Sectigo Limited,L=Salford,ST=Greater Manchester,C=GB’:
  Unable to locally verify the issuer's authority.
HTTP request sent, awaiting response... 302 Found
Location: https://objects.githubusercontent.com/github-production-release-asset-2e65be/670231138/cc61ac03-8dfa-4247-8aef-f29bbafeb0b7?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250416%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250416T074403Z&X-Amz-Expires=300&X-Amz-Signature=8da2400367002456b74abeb4ae6b5acbbf0bac22760cb90a0cca4c0cb4e76f4d&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3DOPNsense-25.1-ufs-efi-vm-amd64.qcow2.bz2&response-content-type=application%2Foctet-stream [following]
--2025-04-16 09:44:03--  https://objects.githubusercontent.com/github-production-release-asset-2e65be/670231138/cc61ac03-8dfa-4247-8aef-f29bbafeb0b7?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250416%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250416T074403Z&X-Amz-Expires=300&X-Amz-Signature=8da2400367002456b74abeb4ae6b5acbbf0bac22760cb90a0cca4c0cb4e76f4d&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3DOPNsense-25.1-ufs-efi-vm-amd64.qcow2.bz2&response-content-type=application%2Foctet-stream
Resolving objects.githubusercontent.com (objects.githubusercontent.com)... 185.199.110.133, 185.199.108.133, 185.199.111.133, ...
Connecting to objects.githubusercontent.com (objects.githubusercontent.com)|185.199.110.133|:443... connected.
WARNING: cannot verify objects.githubusercontent.com's certificate, issued by ‘CN=Sectigo RSA Domain Validation Secure Server CA,O=Sectigo Limited,L=Salford,ST=Greater Manchester,C=GB’:
  Unable to locally verify the issuer's authority.
HTTP request sent, awaiting response... 200 OK
Length: 1322712417 (1.2G) [application/octet-stream]
Saving to: ‘/tmp/opnsense-images/OPNsense-25.1-ufs-efi-vm-amd64.qcow2.bz2’

/tmp/opnsense-images/OPNsense-25 100%[==========================================================>]   1.23G  10.8MB/s    in 5m 10s  

2025-04-16 09:49:14 (4.06 MB/s) - ‘/tmp/opnsense-images/OPNsense-25.1-ufs-efi-vm-amd64.qcow2.bz2’ saved [1322712417/1322712417]
```

## IMPORT VM IMAGE

Default settings are `OPN_VM_IMAGE_VERSION=25.1`, `OPN_VM_IMAGE_ARCH=amd64`, `OPN_VM_IMAGE_CONSOLE=efi`, `OPN_VM_IMAGE_FORMAT=qcow2`

Importiamo l'immagine della VM opnsense per la regione d'interesse

> `export OS_REGION_NAME=GRA11`,`export OS_REGION_NAME=DE1`,`export OS_REGION_NAME=EU-WEST-PAR`,`export OS_REGION_NAME=EU-WEST-MIL`

```bash
(techlab) dletizia@ovh vpc_opnsense-base % oscVPC-importImage-opnsenseVM.sh
+------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field            | Value                                                                                                                                                                                                                                                                                                                                                   |
+------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| checksum         | 549474c8d14d5a279d80ea3af46cdfff                                                                                                                                                                                                                                                                                                                        |
| container_format | bare                                                                                                                                                                                                                                                                                                                                                    |
| created_at       | 2025-04-16T08:28:02Z                                                                                                                                                                                                                                                                                                                                    |
| disk_format      | qcow2                                                                                                                                                                                                                                                                                                                                                   |
| file             | /v2/images/d7f939fb-383f-4471-95e3-b9c3e75500f0/file                                                                                                                                                                                                                                                                                                    |
| id               | d7f939fb-383f-4471-95e3-b9c3e75500f0                                                                                                                                                                                                                                                                                                                    |
| min_disk         | 0                                                                                                                                                                                                                                                                                                                                                       |
| min_ram          | 0                                                                                                                                                                                                                                                                                                                                                       |
| name             | opnsense-25.1-efi                                                                                                                                                                                                                                                                                                                                       |
| owner            | dfee9c2cdc20401fba5b26c024933164                                                                                                                                                                                                                                                                                                                        |
| properties       | os_hash_algo='sha512', os_hash_value='0c6eb8e2ab8cd035b37c1ba0d268d2a9b92ae5da3c2cd9d3a8cbf15c317965c8b044797541a60f4319f2801e98b1e6283e0f5a85b868e0f3939273af47807593', os_hidden='False', owner_specified.openstack.md5='', owner_specified.openstack.object='images/opnsense-25.1-efi', owner_specified.openstack.sha256='', stores='s3.EU-WEST-PAR' |
| protected        | False                                                                                                                                                                                                                                                                                                                                                   |
| schema           | /v2/schemas/image                                                                                                                                                                                                                                                                                                                                       |
| size             | 1322712417                                                                                                                                                                                                                                                                                                                                              |
| status           | active                                                                                                                                                                                                                                                                                                                                                  |
| tags             |                                                                                                                                                                                                                                                                                                                                                         |
| updated_at       | 2025-04-16T08:33:52Z                                                                                                                                                                                                                                                                                                                                    |
| visibility       | shared                                                                                                                                                                                                                                                                                                                                                  |
+------------------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
```

### LIST VM IMAGE

```bash
(techlab) dletizia@ovh vpc_openstack-opnsense % openstack image list | grep opnsense
| d7f939fb-383f-4471-95e3-b9c3e75500f0 | opnsense-25.1-efi                             | active |
```

## CREATE SERVER FROM VM IMAGE

```bash
(techlab) dletizia@ovh vpc_openstack-opnsense % openstack keypair list | grep vpc-techlab_rsa
| vpc-techlab_rsa | 20:27:0b:cf:1a:82:48:73:8d:e9:e2:81:e7:73:96:60 | ssh  |
```

```bash
(techlab) dletizia@ovh vpc_openstack-opnsense % openstack network list | grep VPC_opnsense
| e83d0f93-3b34-4975-8b37-d0454239ede8 | pn-VPC_opnsense-GRA-GREEN-2062 |  |
| 6e59275c-4253-4583-8a5d-b680a2b3319a | pn-VPC_opnsense-GRA-RED-2063   | dbc238b5-73b7-4294-98c5-bb63a6f5c572 |
```

> `VPC_BASTION_NAME=bastion-VPC-opnsense-$VPC_REGION_NAME`
>
> `VPC_NET_NAME=pn-VPC_opnsense-$VPC_REGION_NAME-$VPC_SEGMENT_NAME-$VPC_SEGMENT_ID`

```bash
(techlab) dletizia@ovh vpc_openstack-opnsense % openstack server create \
    --image 'opnsense-25.1-efi' \
    --flavor b3-8 \
    --key-name vpc-techlab_rsa \
    --network pn-VPC_opnsense-GRA-GREEN-2062 \
    --network pn-VPC_opnsense-GRA-RED-2063 \
    --availability-zone eu-west-par-a \
    bastion-VPC-PAR-opnsense
```

# ISO Image via Openstack Horizon (ToDo)

(ToDo)

## GET ISO IMAGE (optional)

[ref](https://pkg.opnsense.org/releases/)
