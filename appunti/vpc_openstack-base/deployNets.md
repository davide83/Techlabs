Deploy Networks
===

Il **VPC 10.42.0.0/16** distribuito su _4 regioni europee_ è composto da altrettante _4 reti private regionali_ **pn-vlan_id_3042-techlabVPC** tipo vrack e _4 sotto reti /24_ come da tabella sottostante.

| # | Region/AZ | Network Name | Network Address | Usable Host Range | Broadcast Address: |
| ----- | ----- | ----- | ----- | ----- | ----- |
| 1 | de1 | Private Subnet 10-42-16-0_24 | 10.42.16.0 | 10.42.16.1 - 10.42.16.254 | 10.42.16.255 |
| 2 | gra11 | Private Subnet 10-42-32_0_24 | 10.42.32.0 | 10.42.1.1 - 10.42.1.254 | 10.42.1.255 |
| 3 | eu-west-mil | Private Subnet 10-42-48-0_24 | 10.42.48.0 | 10.42.48.1 - 10.42.48.254 | 10.42.2.255 |
| 4 | eu-west-par | Private Subnet 10-42-64_0_24 | 10.42.64.0 | 10.42.64.1 - 10.42.64.254 | 10.42.64.255 |

> Set `--host-route` that makes sense on subnets then vRack will do the magic!
>
> IaaS in Paris 3az region is GA and Managed Databases still in Beta and its GA is expected by the Summer
>
> Milan 3az region isn not active yet and it is expected to be only released in GA expected by the Autumn

Scegliendo la sotto rete _10.42.0.0/16_ è possibile creare **255** blocchi di sotto reti con prefisso _/24_. Ogni sotto rete fornisce fino a 254 indirizzi utilizzabili (il primo 1 e l'ultimo indirizzo sono riservati). La _subnet mask_ per un prefisso /24 è 255.255.255.0

Qui di seguito una tabella con tutte le 16 possibili sotto reti /28 per 10.42.16.*
```
Network Address	Usable Host Range	Broadcast Address:
*dvr/gw*10.42.16.0	10.42.16.1 - 10.42.16.14	10.42.16.15
*vrs*10.42.16.16	10.42.16.17 - 10.42.16.30	10.42.16.31
10.42.16.32	10.42.16.33 - 10.42.16.46	10.42.16.47
10.42.16.48	10.42.16.49 - 10.42.16.62	10.42.16.63
*dhcp*10.42.16.64	10.42.16.64 - ...
                   	... - 10.42.16.254	10.42.16.255
```

> *dvr/gw* Openstack di default assegna il primo indirizzo utilizzabile della sottorete come indirizzo del Gateway per la subnet e questo parametro può essere personalizzato da cli
>
> *vrs* vRack Service require a subnet to be globally reserved on all the segment id as part of /24 block and size between /27 and /29

Esportiamo i token come variabili di ambiente e aggiorniamo la OS_REGION_NAME come OpenStack region name quando necessario

```bash
source utils/ovhrc && export OS_REGION_NAME=DE1
```

# Create the private network, subnets and router per each public cloud region

Create Regional private networks, subnets and routers into our multi-regional VPC powered by OVHcloud vRack such as

## Convenzioni

### segmentation id (vlan)

Per convenzione, 3042 è l'unico VLAN ID che identifica questo semplice caso di VPC anche se multi sito

### router as internet gateway

E' possibile associare la rete esterna Ext-Net come gateway esterno al router per accedere agli L3 Service

### dhcp allocation pool

Per convenzione, come spazio di indirizzamento ip dinamico (**DHCP allocation pool**) di ogni sotto rete, allocheremo parte degli _indirizzi host usabili_ e nello specifico faremo solo uso del penultimo ottetto e per l'ultimo indirizzamento usabile. Un esempio, per la rete 172.30.0.0/20 che include gli indirizzi da 172.30.0.1 a 172.30.**_15_**.254 come indirizzi host usabili, allocheremo 172.30.**15.1** e 172.30.**15.254** come **inizio** e **fine** _dhcp allocation pool_ ottenendo 254 indirizzi dei 4091 usabili e sufficienti per lo scopo di questo VPC.

Un esempio, per la rete 10.42.16.0/24 che include gli indirizzi da 10.42.16.1 a 10.42.**_16_**.254 come indirizzi host usabili, allocheremo 10.42.**16.64** e 10.42.**16.254** come **inizio** e **fine** _dhcp allocation pool_ ottenendo 128 indirizzi dei 254 usabili e sufficienti per lo scopo di questo VPC.

### "Public" and "Private" subnets as OS Security Groups

(TODO)

## i.e. LIM (DE1)

- (1az) DE1
    - Export Openstack and VPC envs
        - `export OS_REGION_NAME=DE1`
        - `export VPC_SEGMENT_ID=3042`
        - `export VPC_REGION_NAME=LIM`
        - `export VPC_ROUTER_NAME=router-$VPC_REGION_NAME-ExtGateway-techlabVPC`
        - `export VPC_NET_NAME=pn-vlan_id_$VPC_SEGMENT_ID-techlabVPC`
        - `export VPC_SUBNET_NAME=pnSbnt-$VPC_SEGMENT_ID-$VPC_REGION_NAME-10-42-16-0_24`
    - Create the private network
        - `openstack network create --provider-network-type vrack --provider-segment $VPC_SEGMENT_ID --description "Techlabs' VPC (vlan id $VPC_SEGMENT_ID) Private Subnet 10.42.16.0/24 in $VPC_REGION_NAME region" $VPC_NET_NAME`
    - Create the router
        - `openstack router create --description "Techlabs' VPC (vlan$VPC_SEGMENT_ID) Router in $VPC_REGION_NAME region" $VPC_ROUTER_NAME`
    - Create the private subnet 10.42.16.0/24
        - `openstack subnet create --description "Techlabs' VPC (vlan id $VPC_SEGMENT_ID) Private Subnet 10.42.16.0/24 in $VPC_REGION_NAME region" --network $VPC_NET_NAME --subnet-range 10.42.16.0/24 --dhcp --allocation-pool start=10.42.16.64,end=10.42.16.254 --gateway 10.42.16.1 --host-route destination=10.42.32.0/24,gateway=10.42.32.1 --host-route destination=10.42.48.0/24,gateway=10.42.48.1 --host-route destination=10.42.64.0/24,gateway=10.42.64.1 $VPC_SUBNET_NAME`
    - Downlink the router on the subnet
        - `openstack router add subnet $VPC_ROUTER_NAME $VPC_SUBNET_NAME`
    - Uplink the router on an external network
        - `openstack router set --external-gateway Ext-Net $VPC_ROUTER_NAME`
    ![OS Security Groups](images/ovhTechlabs-VPCvlan3999-network-topology.lim-1az.png)

```sh
(techlab) dletizia@ovh vpc_openstack-base % ./scripts/oscVPC-deployNetwork-lim.sh
+---------------------------+--------------------------------------+
| Field                     | Value                                |
+---------------------------+--------------------------------------+
| admin_state_up            | UP                                   |
| availability_zone_hints   |                                      |
| availability_zones        |                                      |
| created_at                | 2025-03-16T10:33:57Z                 |
| description               | Techlabs' VPC - vlan3999 - in LIM    |
| dns_domain                | None                                 |
| id                        | 63f94e45-364f-4c8b-9f8a-5ce69424d95c |
| ipv4_address_scope        | None                                 |
| ipv6_address_scope        | None                                 |
| is_default                | False                                |
| is_vlan_transparent       | None                                 |
| l2_adjacency              | True                                 |
| mtu                       | 1500                                 |
| name                      | techlabVPC-vlan3999                  |
| port_security_enabled     | True                                 |
| project_id                | dfee9c2cdc20401fba5b26c024933164     |
| provider:network_type     | vrack                                |
| provider:physical_network | None                                 |
| provider:segmentation_id  | 3999                                 |
| qos_policy_id             | None                                 |
| revision_number           | 2                                    |
| router:external           | Internal                             |
| segments                  | None                                 |
| shared                    | False                                |
| status                    | ACTIVE                               |
| subnets                   |                                      |
| tags                      |                                      |
| updated_at                | 2025-03-16T10:33:57Z                 |
+---------------------------+--------------------------------------+
+-------------------------+-------------------------------------------------+
| Field                   | Value                                           |
+-------------------------+-------------------------------------------------+
| admin_state_up          | UP                                              |
| availability_zone_hints |                                                 |
| availability_zones      |                                                 |
| created_at              | 2025-03-16T10:34:00Z                            |
| description             | Techlabs' VPC - vlan3999 - Router in LIM region |
| enable_ndp_proxy        | None                                            |
| external_gateway_info   | null                                            |
| flavor_id               | None                                            |
| id                      | 0177cc5d-84ed-42ad-959c-fbc5ed9b6001            |
| name                    | techlabVPCvlan3999-rtrLIM-internetGateway       |
| project_id              | dfee9c2cdc20401fba5b26c024933164                |
| revision_number         | 2                                               |
| routes                  |                                                 |
| status                  | ACTIVE                                          |
| tags                    |                                                 |
| tenant_id               | dfee9c2cdc20401fba5b26c024933164                |
| updated_at              | 2025-03-16T10:34:00Z                            |
+-------------------------+-------------------------------------------------+
+----------------------+-----------------------------------------------------------------------+
| Field                | Value                                                                 |
+----------------------+-----------------------------------------------------------------------+
| allocation_pools     | 172.30.47.1-172.30.47.254                                             |
| cidr                 | 172.30.32.0/20                                                        |
| created_at           | 2025-03-16T10:34:09Z                                                  |
| description          | Techlabs' VPC - vlan3999 - Public Subnet 172.30.32.0/20 in LIM region |
| dns_nameservers      |                                                                       |
| dns_publish_fixed_ip | None                                                                  |
| enable_dhcp          | True                                                                  |
| gateway_ip           | 172.30.32.1                                                           |
| host_routes          | destination='172.30.32.0/20', gateway='172.30.32.1'                   |
| id                   | 623d5a89-881e-4581-81ef-64384b2af684                                  |
| ip_version           | 4                                                                     |
| ipv6_address_mode    | None                                                                  |
| ipv6_ra_mode         | None                                                                  |
| name                 | techlabVPCvlan3999-sbntLIM-172-30-32-0_20                             |
| network_id           | 63f94e45-364f-4c8b-9f8a-5ce69424d95c                                  |
| project_id           | dfee9c2cdc20401fba5b26c024933164                                      |
| revision_number      | 0                                                                     |
| segment_id           | None                                                                  |
| service_types        |                                                                       |
| subnetpool_id        | None                                                                  |
| tags                 |                                                                       |
| updated_at           | 2025-03-16T10:34:09Z                                                  |
+----------------------+-----------------------------------------------------------------------+
+----------------------+------------------------------------------------------------------------+
| Field                | Value                                                                  |
+----------------------+------------------------------------------------------------------------+
| allocation_pools     | 172.30.63.1-172.30.63.254                                              |
| cidr                 | 172.30.48.0/20                                                         |
| created_at           | 2025-03-16T10:34:20Z                                                   |
| description          | Techlabs' VPC - vlan3999 - Private Subnet 172.30.48.0/20 in LIM region |
| dns_nameservers      |                                                                        |
| dns_publish_fixed_ip | None                                                                   |
| enable_dhcp          | True                                                                   |
| gateway_ip           | 172.30.48.1                                                            |
| host_routes          | destination='172.30.48.0/20', gateway='172.30.48.1'                    |
| id                   | d6e51765-a615-45bd-9cd1-f9f0141d757a                                   |
| ip_version           | 4                                                                      |
| ipv6_address_mode    | None                                                                   |
| ipv6_ra_mode         | None                                                                   |
| name                 | techlabVPCvlan3999-sbntLIM-172-30-48-0_20                              |
| network_id           | 63f94e45-364f-4c8b-9f8a-5ce69424d95c                                   |
| project_id           | dfee9c2cdc20401fba5b26c024933164                                       |
| revision_number      | 0                                                                      |
| segment_id           | None                                                                   |
| service_types        |                                                                        |
| subnetpool_id        | None                                                                   |
| tags                 |                                                                        |
| updated_at           | 2025-03-16T10:34:20Z                                                   |
+----------------------+------------------------------------------------------------------------+
```

# Router QoS

> QoS router policy is small by default

```sh
openstack network qos policy list
```

In my case I got this result as table

| ID | Name | Shared | Default | Project |
| --- | --- | --- | --- | --- | 
| 052b8a9f-eed8-4d2b-82e9-21775718513f | large_router  | True   | False   | 9386d7837e514fc080082efe4892af59 |
| 396aea5a-8642-4cd6-b119-45e657435787 | medium_router | True   | False   | 9386d7837e514fc080082efe4892af59 |
| 396c3fa4-d3ee-43be-8269-891e1f31fecc | XL_router     | True   | False   | 9386d7837e514fc080082efe4892af59 |
| b391fe96-1c14-408b-8e17-3ab20c624ed6 | small_router  | True   | False   | 9386d7837e514fc080082efe4892af59 |
| e23ed6a2-bf5b-40f4-ab31-b54ee18eae31 | 2XL_router    | True   | False   | 9386d7837e514fc080082efe4892af59 |

Change the router QoS policy and adapt to your environment if needed 

```sh
export QOS_ID_OF_YOUR_CHOICE=b391fe96-1c14-408b-8e17-3ab20c624ed6

openstack router set \
    --qos-policy $QOS_ID_OF_YOUR_CHOICE \
    <your-router-id-or-name>
```
