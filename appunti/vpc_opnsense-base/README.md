Techlabs' VPC Openstack - Opnsense
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

# Use case - OPNsense Cluster in HA

OPNsense Cluster in HA.

Scarica l'immagine **ISO** OPNsense da [qui](https://opnsense.org/download/) selezionando le opzioni come da immagine seguente ![choose](images/opnsense-download-iso.png)

Implementiamo il cluster con la seguente architettura ![todo](images/archicible.png)

Sulla base degli indirizzi che sceglieremo per ler reti **WAN** _(RED)_, **LAN** _(GREEN)_ e **HA** _(PINK)_ e per convenzione con l'ambiente _openstack_ a cui delegheremo anche la gestione del servizio _DHCP_:
- gli inidirizzi ip _GW_ saranno entrambi `.1`
- Il _VIP_ per la **LAN** sarà `.10`
- OPNsense1
- - avrà come _indirizzo ip_ `ADDITIONAL_IP_ADDRESS` sulle interfaccia **WAN**
- - avrà come _indirizzo ip_ `.11` sulle interfaccie **LAN** e **HA**
- OPNsense2
- - avrà come _indirizzo ip_ `.12` sulle interfaccie **LAN** e **HA**
- Bastion
- - avrà come _indirizzo ip_ `192.168.xxx.yyy` sull'interfaccia **LAN**. `xxx` dipende dalla **Region** e della **Rete Privata** (vRack vlanId). `yyy` dipende dal servizio dhcp o altra configurazione.

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

#### Reti RED/GREEN/PINK _[/ORANGE/BLUE]_ (WAN/LAN/CARP _[/DMZ/VPN]_)

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
| created_at                | 2025-05-04T13:07:46Z                                                      |
| description               | Techlabs' VPC_opnsense-base (vlan_id: 2042 / GREEN) privateNetwork in PAR |
| dns_domain                | None                                                                      |
| id                        | c58d46d3-47d1-4494-95fc-bc68e8e9acb6                                      |
| ipv4_address_scope        | None                                                                      |
| ipv6_address_scope        | None                                                                      |
| is_default                | False                                                                     |
| is_vlan_transparent       | None                                                                      |
| mtu                       | 1500                                                                      |
| name                      | pn-VPC_opnsense-PAR-GREEN-2042                                            |
| port_security_enabled     | False                                                                     |
| project_id                | e94458a28e8c4f399886c3935b647e9c                                          |
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
| updated_at                | 2025-05-04T13:07:46Z                                                      |
+---------------------------+---------------------------------------------------------------------------+
+----------------------+--------------------------------------------------------------------------------------------------+
| Field                | Value                                                                                            |
+----------------------+--------------------------------------------------------------------------------------------------+
| allocation_pools     | 192.168.42.96-192.168.42.254                                                                     |
| cidr                 | 192.168.42.0/24                                                                                  |
| created_at           | 2025-05-04T13:07:48Z                                                                             |
| description          | Techlabs' VPC_opnsense-base (vlan_id: 2042 / GREEN) Private Subnet 192.168.42.0/24 in PAR region |
| dns_nameservers      |                                                                                                  |
| dns_publish_fixed_ip | None                                                                                             |
| enable_dhcp          | True                                                                                             |
| gateway_ip           | 192.168.42.1                                                                                     |
| host_routes          |                                                                                                  |
| id                   | c86cee82-0627-4887-9479-49c2081d4f6f                                                             |
| ip_version           | 4                                                                                                |
| ipv6_address_mode    | None                                                                                             |
| ipv6_ra_mode         | None                                                                                             |
| name                 | pnSbnt-VPC_opnsense-PAR-GREEN-2042-192-168-42-0_24                                               |
| network_id           | c58d46d3-47d1-4494-95fc-bc68e8e9acb6                                                             |
| project_id           | e94458a28e8c4f399886c3935b647e9c                                                                 |
| revision_number      | 0                                                                                                |
| segment_id           | None                                                                                             |
| service_types        |                                                                                                  |
| subnetpool_id        | None                                                                                             |
| tags                 |                                                                                                  |
| updated_at           | 2025-05-04T13:07:48Z                                                                             |
+----------------------+--------------------------------------------------------------------------------------------------+
\!/ CHECK IF segment GREEN WAS DEPLOYED IN PAR as 2042 SUCCESSFUL \!/
DEPLOYING VPC opnsense RED segment as 0...
+---------------------------+----------------------------------------------------------------------+
| Field                     | Value                                                                |
+---------------------------+----------------------------------------------------------------------+
| admin_state_up            | UP                                                                   |
| availability_zone_hints   | eu-west-par-a, eu-west-par-b, eu-west-par-c                          |
| availability_zones        |                                                                      |
| created_at                | 2025-05-04T13:07:49Z                                                 |
| description               | Techlabs' VPC_opnsense-base (vlan_id: 0 / RED) privateNetwork in PAR |
| dns_domain                | None                                                                 |
| id                        | 1c6541ba-8628-4879-bb81-956bfd54fa9f                                 |
| ipv4_address_scope        | None                                                                 |
| ipv6_address_scope        | None                                                                 |
| is_default                | False                                                                |
| is_vlan_transparent       | None                                                                 |
| mtu                       | 1500                                                                 |
| name                      | pn-VPC_opnsense-PAR-RED-0                                            |
| port_security_enabled     | False                                                                |
| project_id                | e94458a28e8c4f399886c3935b647e9c                                     |
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
| updated_at                | 2025-05-04T13:07:49Z                                                 |
+---------------------------+----------------------------------------------------------------------+
+----------------------+---------------------------------------------------------------------------------------------+
| Field                | Value                                                                                       |
+----------------------+---------------------------------------------------------------------------------------------+
| allocation_pools     | 192.168.43.2-192.168.43.6                                                                   |
| cidr                 | 192.168.43.0/29                                                                             |
| created_at           | 2025-05-04T13:07:50Z                                                                        |
| description          | Techlabs' VPC_opnsense-base (vlan_id: 0 / RED) Private Subnet 192.168.43.0/29 in PAR region |
| dns_nameservers      |                                                                                             |
| dns_publish_fixed_ip | None                                                                                        |
| enable_dhcp          | True                                                                                        |
| gateway_ip           | 192.168.43.1                                                                                |
| host_routes          |                                                                                             |
| id                   | 67d12457-1c81-4c4a-af91-a4ef603da3f8                                                        |
| ip_version           | 4                                                                                           |
| ipv6_address_mode    | None                                                                                        |
| ipv6_ra_mode         | None                                                                                        |
| name                 | pnSbnt-VPC_opnsense-PAR-RED-0-192-168-43-0_29                                               |
| network_id           | 1c6541ba-8628-4879-bb81-956bfd54fa9f                                                        |
| project_id           | e94458a28e8c4f399886c3935b647e9c                                                            |
| revision_number      | 0                                                                                           |
| segment_id           | None                                                                                        |
| service_types        |                                                                                             |
| subnetpool_id        | None                                                                                        |
| tags                 |                                                                                             |
| updated_at           | 2025-05-04T13:07:50Z                                                                        |
+----------------------+---------------------------------------------------------------------------------------------+
\!/ CHECK IF segment RED WAS DEPLOYED IN PAR as 0 SUCCESSFUL \!/
DEPLOYING VPC opnsense ORANGE segment as 2044...
+---------------------------+----------------------------------------------------------------------------+
| Field                     | Value                                                                      |
+---------------------------+----------------------------------------------------------------------------+
| admin_state_up            | UP                                                                         |
| availability_zone_hints   | eu-west-par-a, eu-west-par-b, eu-west-par-c                                |
| availability_zones        |                                                                            |
| created_at                | 2025-05-04T13:07:51Z                                                       |
| description               | Techlabs' VPC_opnsense-base (vlan_id: 2044 / ORANGE) privateNetwork in PAR |
| dns_domain                | None                                                                       |
| id                        | f8113a45-9243-4ad6-8f79-0d0a06b43995                                       |
| ipv4_address_scope        | None                                                                       |
| ipv6_address_scope        | None                                                                       |
| is_default                | False                                                                      |
| is_vlan_transparent       | None                                                                       |
| mtu                       | 1500                                                                       |
| name                      | pn-VPC_opnsense-PAR-ORANGE-2044                                            |
| port_security_enabled     | False                                                                      |
| project_id                | e94458a28e8c4f399886c3935b647e9c                                           |
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
| updated_at                | 2025-05-04T13:07:51Z                                                       |
+---------------------------+----------------------------------------------------------------------------+
+----------------------+---------------------------------------------------------------------------------------------------+
| Field                | Value                                                                                             |
+----------------------+---------------------------------------------------------------------------------------------------+
| allocation_pools     | 192.168.44.96-192.168.44.254                                                                      |
| cidr                 | 192.168.44.0/24                                                                                   |
| created_at           | 2025-05-04T13:07:52Z                                                                              |
| description          | Techlabs' VPC_opnsense-base (vlan_id: 2044 / ORANGE) Private Subnet 192.168.44.0/24 in PAR region |
| dns_nameservers      |                                                                                                   |
| dns_publish_fixed_ip | None                                                                                              |
| enable_dhcp          | True                                                                                              |
| gateway_ip           | 192.168.44.1                                                                                      |
| host_routes          |                                                                                                   |
| id                   | fb42bbdb-b2d2-4cff-88d1-e69814d0bc79                                                              |
| ip_version           | 4                                                                                                 |
| ipv6_address_mode    | None                                                                                              |
| ipv6_ra_mode         | None                                                                                              |
| name                 | pnSbnt-VPC_opnsense-PAR-ORANGE-2044-192-168-44-0_24                                               |
| network_id           | f8113a45-9243-4ad6-8f79-0d0a06b43995                                                              |
| project_id           | e94458a28e8c4f399886c3935b647e9c                                                                  |
| revision_number      | 0                                                                                                 |
| segment_id           | None                                                                                              |
| service_types        |                                                                                                   |
| subnetpool_id        | None                                                                                              |
| tags                 |                                                                                                   |
| updated_at           | 2025-05-04T13:07:52Z                                                                              |
+----------------------+---------------------------------------------------------------------------------------------------+
\!/ CHECK IF segment ORANGE WAS DEPLOYED IN PAR as 2044 SUCCESSFUL \!/
DEPLOYING VPC opnsense BLUE segment as 2045...
+---------------------------+--------------------------------------------------------------------------+
| Field                     | Value                                                                    |
+---------------------------+--------------------------------------------------------------------------+
| admin_state_up            | UP                                                                       |
| availability_zone_hints   | eu-west-par-a, eu-west-par-b, eu-west-par-c                              |
| availability_zones        |                                                                          |
| created_at                | 2025-05-04T13:07:53Z                                                     |
| description               | Techlabs' VPC_opnsense-base (vlan_id: 2045 / BLUE) privateNetwork in PAR |
| dns_domain                | None                                                                     |
| id                        | 5897f3d1-a87b-47da-9e51-36055e74ac6c                                     |
| ipv4_address_scope        | None                                                                     |
| ipv6_address_scope        | None                                                                     |
| is_default                | False                                                                    |
| is_vlan_transparent       | None                                                                     |
| mtu                       | 1500                                                                     |
| name                      | pn-VPC_opnsense-PAR-BLUE-2045                                            |
| port_security_enabled     | False                                                                    |
| project_id                | e94458a28e8c4f399886c3935b647e9c                                         |
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
| updated_at                | 2025-05-04T13:07:53Z                                                     |
+---------------------------+--------------------------------------------------------------------------+
+----------------------+-------------------------------------------------------------------------------------------------+
| Field                | Value                                                                                           |
+----------------------+-------------------------------------------------------------------------------------------------+
| allocation_pools     | 192.168.45.96-192.168.45.254                                                                    |
| cidr                 | 192.168.45.0/24                                                                                 |
| created_at           | 2025-05-04T13:07:54Z                                                                            |
| description          | Techlabs' VPC_opnsense-base (vlan_id: 2045 / BLUE) Private Subnet 192.168.45.0/24 in PAR region |
| dns_nameservers      |                                                                                                 |
| dns_publish_fixed_ip | None                                                                                            |
| enable_dhcp          | True                                                                                            |
| gateway_ip           | 192.168.45.1                                                                                    |
| host_routes          |                                                                                                 |
| id                   | 64d910be-4318-4a77-9600-2586e2382865                                                            |
| ip_version           | 4                                                                                               |
| ipv6_address_mode    | None                                                                                            |
| ipv6_ra_mode         | None                                                                                            |
| name                 | pnSbnt-VPC_opnsense-PAR-BLUE-2045-192-168-45-0_24                                               |
| network_id           | 5897f3d1-a87b-47da-9e51-36055e74ac6c                                                            |
| project_id           | e94458a28e8c4f399886c3935b647e9c                                                                |
| revision_number      | 0                                                                                               |
| segment_id           | None                                                                                            |
| service_types        |                                                                                                 |
| subnetpool_id        | None                                                                                            |
| tags                 |                                                                                                 |
| updated_at           | 2025-05-04T13:07:54Z                                                                            |
+----------------------+-------------------------------------------------------------------------------------------------+
\!/ CHECK IF segment BLUE WAS DEPLOYED IN PAR as 2045 SUCCESSFUL \!/
DEPLOYING VPC opnsense PINK segment as 2046...
+---------------------------+--------------------------------------------------------------------------+
| Field                     | Value                                                                    |
+---------------------------+--------------------------------------------------------------------------+
| admin_state_up            | UP                                                                       |
| availability_zone_hints   | eu-west-par-a, eu-west-par-b, eu-west-par-c                              |
| availability_zones        |                                                                          |
| created_at                | 2025-05-04T13:07:56Z                                                     |
| description               | Techlabs' VPC_opnsense-base (vlan_id: 2046 / PINK) privateNetwork in PAR |
| dns_domain                | None                                                                     |
| id                        | b0e8a967-b5f9-4f10-870d-889b0a0a1166                                     |
| ipv4_address_scope        | None                                                                     |
| ipv6_address_scope        | None                                                                     |
| is_default                | False                                                                    |
| is_vlan_transparent       | None                                                                     |
| mtu                       | 1500                                                                     |
| name                      | pn-VPC_opnsense-PAR-PINK-2046                                            |
| port_security_enabled     | False                                                                    |
| project_id                | e94458a28e8c4f399886c3935b647e9c                                         |
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
| updated_at                | 2025-05-04T13:07:56Z                                                     |
+---------------------------+--------------------------------------------------------------------------+
+----------------------+-------------------------------------------------------------------------------------------------+
| Field                | Value                                                                                           |
+----------------------+-------------------------------------------------------------------------------------------------+
| allocation_pools     | 192.168.46.1-192.168.46.6                                                                       |
| cidr                 | 192.168.46.0/29                                                                                 |
| created_at           | 2025-05-04T13:07:57Z                                                                            |
| description          | Techlabs' VPC_opnsense-base (vlan_id: 2046 / PINK) Private Subnet 192.168.46.0/29 in PAR region |
| dns_nameservers      |                                                                                                 |
| dns_publish_fixed_ip | None                                                                                            |
| enable_dhcp          | True                                                                                            |
| gateway_ip           | None                                                                                            |
| host_routes          |                                                                                                 |
| id                   | b1e03146-d10c-45ed-8b32-1118729dae40                                                            |
| ip_version           | 4                                                                                               |
| ipv6_address_mode    | None                                                                                            |
| ipv6_ra_mode         | None                                                                                            |
| name                 | pnSbnt-VPC_opnsense-PAR-PINK-2046-192-168-46-0_29                                               |
| network_id           | b0e8a967-b5f9-4f10-870d-889b0a0a1166                                                            |
| project_id           | e94458a28e8c4f399886c3935b647e9c                                                                |
| revision_number      | 0                                                                                               |
| segment_id           | None                                                                                            |
| service_types        |                                                                                                 |
| subnetpool_id        | None                                                                                            |
| tags                 |                                                                                                 |
| updated_at           | 2025-05-04T13:07:57Z                                                                            |
+----------------------+-------------------------------------------------------------------------------------------------+
\!/ CHECK IF segment PINK WAS DEPLOYED IN PAR as 2046 SUCCESSFUL \!/
\!/ CHECK IF VPC opnsenseNETWORKs WERE DEPLOYED IN PAR SUCCESSFUL \!/
```

#### VPC 198.168.0.0/16

per esempio: 

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

##### add Additional IP as opnsense alias

> NOT EXPLORED YET!

```bash
ifconfig vtnet1 addaddr 57.130.12.88/30
sysctl -w net.inet.ip.route.debug=2
ifconfig vtnet1 plumb
```

| vpc_region | vpc_net_name | vpc_net_id | os_net_name | vpc_subnet |
| ----- | ----- | ----- | ----- | ----- |
| PAR | GREEN | 2042 | pn-VPC_opnsense-GRA-GREEN-2042 | 192.168.42.0/24 |
| PAR | RED | 0 | pn-VPC_opnsense-PAR-RED-0 | 192.168.43.0/29 |
| PAR | ORANGE | 2044 | pn-VPC_opnsense-PAR-ORANGE-2044 | 192.168.44.0/24 |
| PAR | BLUE | 2045 | pn-VPC_opnsense-PAR-BLUE-2045 | 192.168.45.0/24 |
| PAR | PINK | 2046 | pn-VPC_opnsense-PAR-PINK-2046 | 192.168.46.0/29 |

![alt text](images/pn-VPC_opnsense-PAR-X-Y.png)

> Milano _(EU-SOUTH-MIL)_ come segue

| vpc_region | vpc_net_name | vpc_net_id | os_net_name | vpc_subnet |
| ----- | ----- | ----- | ----- | ----- |
| MIL | GREEN | 2052 | pn-VPC_opnsense-MIL-GREEN-2052 | 192.168.52.0/24 |
| MIL | RED | 0 | pn-VPC_opnsense-MIL-RED-0 | 192.168.53.0/29 |
| MIL | ORANGE | 2054 | pn-VPC_opnsense-MIL-ORANGE-2054 | 192.168.54.0/24 |
| MIL | BLUE | 2055 | pn-VPC_opnsense-MIL-BLUE-2055 | 192.168.55.0/24 |
| MIL | PINK | 2056 | pn-VPC_opnsense-MIL-PINK-2056 | 192.168.56.0/29 |

> Gravelines _(GRA11)_ come segue

| vpc_region | vpc_net_name | vpc_net_id | os_net_name | vpc_subnet |
| ----- | ----- | ----- | ----- | ----- |
| GRA | GREEN | 2062 | pn-VPC_opnsense-GRA-GREEN-2062 | 192.168.62.0/24 |
| GRA | RED | 0 | pn-VPC_opnsense-GRA-RED-0 | 192.168.63.0/29 |
| GRA | ORANGE | 2064 | pn-VPC_opnsense-GRA-ORANGE-2064 | 192.168.64.0/24 |
| GRA | BLUE | 2065 | pn-VPC_opnsense-GRA-BLUE-2065 | 192.168.65.0/24 |
| GRA | PINK | 2066 | pn-VPC_opnsense-GRA-PINK-2066 | 192.168.66.0/29 |

> Limburg _(DE1)_ come segue

| vpc_region | vpc_net_name | vpc_net_id | os_net_name | vpc_subnet |
| ----- | ----- | ----- | ----- | ----- |
| LIM | GREEN | 2072 | pn-VPC_opnsense-LIM-GREEN-2072 | 192.168.72.0/24 |
| LIM | RED | 0 | pn-VPC_opnsense-LIM-RED-0 | 192.168.73.0/29 |
| LIM | ORANGE | 2074 | pn-VPC_opnsense-GRA-ORANGE-2074 | 192.168.74.0/24 |
| LIM | BLUE | 2075 | pn-VPC_opnsense-GRA-BLUE-2075 | 192.168.75.0/24 |
| LIM | PINK | 2076 | pn-VPC_opnsense-GRA-PINK-2076 | 192.168.76.0/29 |

# VM Image via Openstack Client

> `OPN_RELEASE=25.1`

## GET VM IMAGE

[ref](https://github.com/maurice-w/opnsense-vm-images/releases)

Default settings are `OPN_VM_IMAGE_VERSION=25.1`, `OPN_VM_IMAGE_ARCH=amd64`, `OPN_VM_IMAGE_CONSOLE=efi`, `OPN_VM_IMAGE_DISK_FORMAT=qcow2`

```bash
(techlab) dletizia@ovh vpc_opnsense-base % ./scripts/oscVPC-getImage-opnsenseVM.sh
--2025-05-04 12:44:28--  https://github.com/maurice-w/opnsense-vm-images/releases/download/25.1/OPNsense-25.1-ufs-efi-vm-amd64.qcow2.bz2
Resolving github.com (github.com)... 140.82.121.3
Connecting to github.com (github.com)|140.82.121.3|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://objects.githubusercontent.com/github-production-release-asset-2e65be/670231138/cc61ac03-8dfa-4247-8aef-f29bbafeb0b7?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250504%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250504T124428Z&X-Amz-Expires=300&X-Amz-Signature=53be324c52305305b9fcfc5ae76073fdbf4fe11dbac6d5d71555776c75ea57df&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3DOPNsense-25.1-ufs-efi-vm-amd64.qcow2.bz2&response-content-type=application%2Foctet-stream [following]
--2025-05-04 12:44:28--  https://objects.githubusercontent.com/github-production-release-asset-2e65be/670231138/cc61ac03-8dfa-4247-8aef-f29bbafeb0b7?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250504%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250504T124428Z&X-Amz-Expires=300&X-Amz-Signature=53be324c52305305b9fcfc5ae76073fdbf4fe11dbac6d5d71555776c75ea57df&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3DOPNsense-25.1-ufs-efi-vm-amd64.qcow2.bz2&response-content-type=application%2Foctet-stream
Resolving objects.githubusercontent.com (objects.githubusercontent.com)... 185.199.109.133, 185.199.110.133, 185.199.111.133, ...
Connecting to objects.githubusercontent.com (objects.githubusercontent.com)|185.199.109.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 1322712417 (1.2G) [application/octet-stream]
Saving to: ‘/tmp/opnsense-images/OPNsense-25.1-ufs-efi-vm-amd64.qcow2.bz2’

/tmp/opnsense-images/OPNs 100%[=====================================>]   1.23G  35.7MB/s    in 34s     

2025-05-04 12:45:02 (37.6 MB/s) - ‘/tmp/opnsense-images/OPNsense-25.1-ufs-efi-vm-amd64.qcow2.bz2’ saved [1322712417/1322712417]
```

### Get ISO

[ref](https://opnsense.org/download/)

Default settings are `OPN_ISO_IMAGE_VERSION=25.1`, `OPN_ISO_IMAGE_ARCH=amd64`, `OPN_ISO_IMAGE_CONSOLE=dvd`, `OPN_ISO_IMAGE_DISK_FORMAT=iso`

```bash
(techlab) dletizia@ovh vpc_opnsense-base % scripts/oscVPC-getImage-opnsenseISO.sh
ECHO .> Downloading...
--2025-05-04 20:51:26--  https://pkg.opnsense.org/releases/25.1/OPNsense-25.1-dvd-amd64.iso.bz2
Resolving pkg.opnsense.org (pkg.opnsense.org)... 89.149.222.99, 2001:1af8:5300:a010:1::1
Connecting to pkg.opnsense.org (pkg.opnsense.org)|89.149.222.99|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 521440733 (497M) [application/x-bzip2]
Saving to: ‘/tmp/opnsense-images/OPNsense-25.1-dvd-amd64.iso.bz2’

/tmp/opnsense-images/OPNs 100%[=====================================>] 497.28M   246MB/s    in 2.0s    

2025-05-04 20:51:29 (246 MB/s) - ‘/tmp/opnsense-images/OPNsense-25.1-dvd-amd64.iso.bz2’ saved [521440733/521440733]

ECHO .> /tmp/opnsense-images/OPNsense-25.1-dvd-amd64.iso.bz2 Downloaded!
ECHO .> Extracting...
ECHO .> /tmp/opnsense-images/OPNsense-25.1-dvd-amd64.iso Extracted!
```

## IMPORT VM IMAGE

Default settings are `OPN_VM_IMAGE_VERSION=25.1`, `OPN_VM_IMAGE_ARCH=amd64`, `OPN_VM_IMAGE_CONSOLE=efi`, `OPN_VM_IMAGE_FORMAT=qcow2`

Importiamo l'immagine della VM opnsense per la regione d'interesse

> `export OS_REGION_NAME=GRA11`,`export OS_REGION_NAME=DE1`,`export OS_REGION_NAME=EU-WEST-PAR`,`export OS_REGION_NAME=EU-WEST-MIL`

```bash
(techlab) dletizia@ovh vpc_opnsense-base % oscVPC-importImage-opnsenseVM.sh
+------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field            | Value                                                                                                                                                              |
+------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| container_format | bare                                                                                                                                                               |
| created_at       | 2025-05-04T12:48:07Z                                                                                                                                               |
| disk_format      | qcow2                                                                                                                                                              |
| file             | /v2/images/***/file                                                                                                               |
| id               | ***                                                                                                                               |
| min_disk         | 0                                                                                                                                                                  |
| min_ram          | 0                                                                                                                                                                  |
| name             | OPNsense-25.1-ufs-efi-vm-amd64                                                                                                                                     |
| owner            | ***                                                                                                                                   |
| properties       | os_hidden='False', owner_specified.openstack.md5='', owner_specified.openstack.object='images/OPNsense-25.1-ufs-efi-vm-amd64', owner_specified.openstack.sha256='' |
| protected        | False                                                                                                                                                              |
| schema           | /v2/schemas/image                                                                                                                                                  |
| status           | queued                                                                                                                                                             |
| tags             |                                                                                                                                                                    |
| updated_at       | 2025-05-04T12:48:07Z                                                                                                                                               |
| visibility       | shared                                                                                                                                                             |
+------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
```

### LIST VM IMAGE

```bash
(techlab) dletizia@ovh vpc_openstack-opnsense % openstack image list | grep OPNsense
| 369af85b-a2ce-458e-bb87-1df1d8b6158e | OPNsense-25.1-ufs-efi-vm-amd64                | active |
| 5b7b1bc5-52b6-477f-8a98-9e5a0aa316c9 | OPNsense-25.1-ufs-serial-vm-amd64             | active |
```

## CREATE SERVER FROM VM IMAGE

```bash
(techlab) dletizia@ovh vpc_openstack-opnsense % openstack network list | grep VPC_opnsense
| 1c6541ba-8628-4879-bb81-956bfd54fa9f | pn-VPC_opnsense-PAR-RED-0       |         67d12457-1c81-4c4a-af91-a4ef603da3f8   |
| 5897f3d1-a87b-47da-9e51-36055e74ac6c | pn-VPC_opnsense-PAR-BLUE-2045   | 64d910be-4318-4a77-9600-2586e2382865   |
| b0e8a967-b5f9-4f10-870d-889b0a0a1166 | pn-VPC_opnsense-PAR-PINK-2046   | b1e03146-d10c-45ed-8b32-1118729dae40   |
| c58d46d3-47d1-4494-95fc-bc68e8e9acb6 | pn-VPC_opnsense-PAR-GREEN-2042  | c86cee82-0627-4887-9479-49c2081d4f6f   |
| f8113a45-9243-4ad6-8f79-0d0a06b43995 | pn-VPC_opnsense-PAR-ORANGE-2044 | fb42bbdb-b2d2-4cff-88d1-e69814d0bc79   |
```

### upload ssh keypair
```bash
(techlab) dletizia@ovh vpc_openstack-opnsense % scripts/oscVPC-deplopyAllKeys.sh
DEPLOYING SSHKEY IN PAR ...
+-------------+-------------------------------------------------+
| Field       | Value                                           |
+-------------+-------------------------------------------------+
| created_at  | None                                            |
| fingerprint | 20:27:0b:cf:1a:82:48:73:8d:e9:e2:81:e7:73:96:60 |
| id          | vpc-techlab_rsa                                 |
| is_deleted  | None                                            |
| name        | vpc-techlab_rsa                                 |
| type        | ssh                                             |
| user_id     | c6573dbfe8d44f29a6a38233ebe5bbcf                |
+-------------+-------------------------------------------------+
\!/ CHECK IF THE SSHKEY WAS DEPLOYED IN PAR SUCCESSFUL \!/
```

#### list uploaded ssh keypair
```bash
(techlab) dletizia@ovh vpc_openstack-opnsense % openstack keypair list | grep vpc-techlab_rsa
| vpc-techlab_rsa | 20:27:0b:cf:1a:82:48:73:8d:e9:e2:81:e7:73:96:60 | ssh  |
```

### deploy

> `VPC_BASTION_NAME=bastion-VPC-opnsense-$VPC_REGION_NAME`
>
> `VPC_NET_NAME=pn-VPC_opnsense-$VPC_REGION_NAME-$VPC_SEGMENT_NAME-$VPC_SEGMENT_ID`

#### deployAllOPNs'

```bash
(techlab) dletizia@ovh vpc_openstack-opnsense % openstack server create \
  --image OPNsense-25.1-ufs-<efi|serial>-vm-amd64 \
  --flavor b3-32 \
  --network pn-VPC_opnsense-PAR-GREEN-2042 \
  --network pn-VPC_opnsense-PAR-RED-0 \
  --network pn-VPC_opnsense-PAR-PINK-2046 \
  --network pn-VPC_opnsense-PAR-ORANGE-2044 \
  --network pn-VPC_opnsense-PAR-BLUE-2045 \
  --availability-zone eu-west-par-<a|b|c> \
  <opnsense-node-name>
```

```bash
(techlab) dletizia@ovh vpc_openstack-opnsense % scripts/oscVPC-deployAllOPNs.sh

```

#### deployAllBastions'
```bash
(techlab) dletizia@ovh vpc_openstack-opnsense % openstack server create \
  --image 'Ubuntu 24.04' \
  --flavor c3-4 \
  --network Ext-Net \
  --network pn-VPC_opnsense-PAR-GREEN-2042 \
  --availability-zone eu-west-par-<a|b|c> \
  <opnsense-node-name>
```

```bash
(techlab) dletizia@ovh vpc_openstack-opnsense % scripts/oscVPC-deployAllBastions.sh

```

# ISO Image via Openstack Horizon

_NB_

## _Scripted_
Like other appliance, create the initial RAW image based on ISO in the region you want to deploy your cluster. For that :
1. Download the Iso on opnsense site
1. 1. see `scripts/oscVPC-getImage-opnsenseISO.sh` :- D
2. Create the image of the iso : `openstack image create --disk-format iso --file opnsense.iso OPNsense-25.1.iso`
2. 1. see `scripts/oscVPC-importImage-opnsenseISO.sh` :- D

### _Not scripted_ yet!

> `Openstack Horizon` is a friendly **GUI** for the above procedure :- )

1. Create a instance that will boot on OPNsense iso : `openstack server create --image OPNsense-25.1.iso --flavor c3-4 OPNsense-25.1install --network Ext-Net`
2. Create a 20Gb volume : `openstack volume create  --size 20 --bootable OPNsense-25.1install`
3. Attach it to the instance : `openstack server add volume OPNsense-25.1install OPNsense-25.1install --dev /dev/vda`
4. Proceed to the basic install of OPNsense via Horizon console : `WARNING proceed with installer user !!!!!!!!!!`
5. Once OPNsense is installed stop the instance : `openstack server stop OPNsense-25.1install`
6. Delete the instance : `openstack server delete OPNsense-25.1install`
7. Create a new image based on the volume created before : `openstack image create --volume OPNsense-25.1install OPNsense-25.1`

(ToDo)

## GET ISO IMAGE (optional)

[ref](https://pkg.opnsense.org/releases/)
