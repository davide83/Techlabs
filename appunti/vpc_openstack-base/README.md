Techlab's VPC
===

Un altro modo semplice di mettere in opera un _Virtual Private Cloud_ distribuito su **quattro** regioni _public cloud_ europee dove saranno ospitati alcuni servizi e raggiungibili privatamente anche se tra di loro geograficamente distanti o esposti pubblicamente se necessario.

> Yet Another Multi-region VPC
>
> YAMVPC _powered by vRack_

# Prerequisiti

Prima di iniziare, assicuriamoci di avere:

- **OVHcloud account**: accesso allo Spazio Cliente OVHcloud [_manager_](https://www.ovh.com/auth/?action=gotomanager&ovhSubsidiary=IT)
- **Public Cloud project**: accesso a un progetto public cloud o [creane uno nuovo](https://www.ovh.com/manager/#/public-cloud/pci/projects/new)
- **Console Bash**: assicurarsi di disporre di una _console_ **Bash** installata
- **osc**: assicurarsi di disporre di un utente OpenStack per l'OpenStack Command Line Client. [ref. utils/ovhrc](https://github.com/ovh/public-cloud-examples/blob/main/configuration/shell/README.md)

## Configurazione

> Clone Techlab's git repo (TODO)
>
> Cloniamo il repository git del Techlab (TODO)

Configuriamo il file **ovhrc** e riversiamo il suo contenuto nella shell corrente

> `cp utils/ovhrc.template utils/ovhrc`
>
> `. utils/ovhrc` oppure `source utils/ovhrc`

Per dettagli ulteriori [_utils_](utils/) oppure la referenza sovramenzionata.

# Creiamo la rete privata, aka VPC

by regional and zonal Public Cloud Service

> we will focus on IPv4
>
> **VPC 10.42.0.0/16** (pn-vlan_id_3042-techlabVPC)

## VPC Subnets

### Come determinare gli intervalli di indirizzi IP da utilizzare

È buona pratica specificare un blocco CIDR (con prefisso /16 o minore) dagli intervalli di **indirizzi IPv4 privati** come specificato nella RFC 1918. Ecco i blocchi di indirizzi privati a cui è possibile fare riferimento:
- 10.0.0.0 – 10.255.255.255 (10/8 prefix)
- 172.16.0.0 – 172.30.255.255 (172.16/12 prefix)
- 192.168.0.0 – 192.168.255.255 (192.168/16 prefix)

> [online IP subnet calculator](https://www.calculator.net/ip-subnet-calculator.html)
>
> _NB_ 172.31.0.0/17 is used by ovh on public cloud networks for _internal_fip_subnet
>
> _NB_ managed kube priv subnets reserved as [known-limits](https://help.ovhcloud.com/csm/it-public-cloud-kubernetes-using-vrack?id=kb_article_view&sysparm_article=KB0055388#known-limits)
>
> > 10.2.0.0/16 # Subnet used by pods
> >
> > 10.3.0.0/16 # Subnet used by services
> >
> > 172.17.0.0/16 # Subnet used by the Docker daemon

### VPC 10.42.0.0/16

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

## Deploiamo le componenti di rete per ogni regione public cloud

Deploiamo le componenti di rete per ogni regione public cloud come reti private, subnet e router nel nostro VPC multi regionale interconnesso dalla vRack di OVHcloud.

Possiamo agevolare la messa in opera delle componenti necessarie al progetto automatizzando le operazioni, per esempio eseguendo i seguenti script. Consultiamo il file [_deployNets.md_](deployNets.md) e la cartella [_scripts_](scripts/) per dettagli ulteriori.

> Uplink the router on an external network
>
> Downlink the router on the previously created subnet

### Deploy all
```sh
(techlab) dletizia@ovh vpc_openstack-base % ./scripts/oscVPC-deployAllNetworks.sh
```
### Deploy one by one
#### 1-AZ
##### GRA (GRA11)
```sh
(techlab) dletizia@ovh vpc_openstack-base % ./scripts/oscVPC-deployNetwork-gra.sh
```
##### LIM (DE1)
```sh
(techlab) dletizia@ovh vpc_openstack-base % ./scripts/oscVPC-deployNetwork-lim.sh
```
### 3-AZ
#### PAR (EU-WEST-PAR)
```sh
(techlab) dletizia@ovh vpc_openstack-base % ./scripts/oscVPC-deployNetwork-par.sh
```
#### MIL (EU-WEST-MIL)
> Milan 3az region is not active yet and it is expected to be only released in GA after the Summer
```sh
(techlab) dletizia@ovh vpc_openstack-base % ./scripts/oscVPC-deployNetwork-mil.sh
```

### Verifichiamo la messa in opera

E' possibile utilizzare lo strumento [ovhAPI.sh](https://github.com/ovh/public-cloud-examples/blob/main/configuration/shell/README.md), disponibile per le console Bash compatibili, per interrogare le OVHcloud API invece delle OpenStack API precedentemente utilizzate, giovando così di fetch su tutte le regioni e aggregate da ovh aggratis.

Quale è l'**id**entificativo della rete privata **VPC** con _segment id 3042_, aka _vRack vlan id_?
```sh
(techlab) dletizia@ovh vpc_openstack-base % utils/ovhAPI.sh GET /cloud/project/${OS_TENANT_ID}/network/private | jq -r '.[] | select(.vlanId==3042) |.id'
pn-1097604_3042
```

Quale nome è stato assegnato al VPC?
```sh
(techlab) dletizia@ovh vpc_openstack-base % utils/ovhAPI.sh GET /cloud/project/${OS_TENANT_ID}/network/private | jq -r '.[] | select(.vlanId==3042) |.name'
pn-vlan_id_3042-techlabVPC
```

In quali regioni è stato deploiato?
```sh
(techlab) dletizia@ovh vpc_openstack-base % utils/ovhAPI.sh GET /cloud/project/${OS_TENANT_ID}/network/private | jq -r '.[] | select(.vlanId==3042) |.regions'
[
  {
    "region": "EU-WEST-PAR",
    "status": "ACTIVE",
    "openstackId": "d6166150-dd20-4f39-b114-07ef46ba2f94"
  },
  {
    "region": "DE1",
    "status": "ACTIVE",
    "openstackId": "63f94e45-364f-4c8b-9f8a-5ce69424d95c"
  },
  {
    "region": "GRA11",
    "status": "ACTIVE",
    "openstackId": "e5f70b8a-bc26-4c74-abe7-22dd246c45e2"
  }
]
```

#### MacOS fix

> NB l'originale [ovhAPI.sh](utils/ovhAPI.sh) qualora non si volesse [installare la dipendenza dell'utility sha1sum via brew](https://github.com/ovh/public-cloud-examples/blob/main/configuration/shell/dependencies/macos/installDeps.sh), può essere modificata per funzionare anche in ambiente MacOS (darwin) e segue una nota tipo snippet

```bash
# --- OMITTED ABOVE CODE --- 
# METHOD
case $METHOD in
        GET|POST|PUT|DELETE) TESTRESULT=0;;
        *) echo "ERROR - Input Method not allowed - Must be in [GET|POST|PUT|DELETE]"
        TESTRESULT=2
        exit $TESTRESULT;;
esac

# --- 8< --- 

# Tests OS TYPE
# https://megamorf.gitlab.io/2019/06/10/working-with-checksums-on-macos-and-linux/
# https://gist.github.com/bilalelreda/d82c8696cb585d2b698805e1e6d6cdf4
if [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        MY_OS_SHA1cmd='shasum -a 1'
else
        # ...
        MY_OS_SHA1cmd=sha1sum
fi
# Function SHA1_HEX
function SHA1_HEX {
        echo -n "${1}" | $MY_OS_SHA1cmd | sed 's/ .*//'
}

# --- 8< --- 

# Set API variables & signature
FULLQUERY="${OVH_BASEURL}${QUERY}"
TIMESTAMP="$(curl -s ${OVH_BASEURL}/auth/time)"
METHOD="${METHOD}"
PRESIGNATURE="${OVH_APPLICATION_SECRET}+${OVH_CONSUMER_KEY}+${METHOD}+${FULLQUERY}+${BODY}+${TIMESTAMP}"
SIGNATURE="\$1\$$(SHA1_HEX "${PRESIGNATURE}")"
# --- OMITTED BELOW CODE --- 
```

> It works! [my gh gists](https://gist.github.com/davide83/8e448804b75935aa3455b4ef9116d776)
>
> TODO - Aprire una GH Issue, o inviare una PR sul repo ovh. 
> 
> sha1sum via brew, oppure [installare TUTTE le dipendenze MacOS per la shell](https://github.com/ovh/public-cloud-examples/blob/main/configuration/shell/dependencies/macos/installDeps.sh).

## Topologia di rete

### Network Topology

- 1-AZ
    - GRA (GRA11) ![Network Topology](images/ovhTechlabs-VPCvlan3999-network-topology.gra-1az.png)
    - LIM (DE1) ![Network Topology](images/ovhTechlabs-VPCvlan3999-network-topology.lim-1az.png)
- 3-AZ
    - MIL (EU-SOUTH-MIL) ![Network Topology](images/ovhTechlabs-VPCvlan3999-network-topology.mil-3az.png)
    - PAR (EU-WEST-PAR) ![Network Topology](images/ovhTechlabs-VPCvlan3999-network-topology.par-3az.png)

# Deploy Jump Host

Un jump host, noto anche come server jumpbox o jumpbox, concede agli utenti autorizzati l'accesso a una rete remota, consentendo loro di risolvere i problemi e gestire i dispositivi all'interno della LAN. 

![Jump host](images/jumphost.png)
[ref. Tailscale](https://tailscale.com/learn/access-remote-server-jump-host)

Possiamo agevolare la messa in opera del Jump Host automatizzando le operazioni, per esempio eseguendo i seguenti script.
Consultiamo il file [_deployJumpHots.md_](deployJumpHots.md) e la cartella [_scripts_](scripts/) per dettagli ulteriori.

## Deploy Keypairs

```sh
(techlab) dletizia@ovh vpc_openstack-base % ./scripts/oscVPC-deployAllKeys.sh
```

### Deploy all
```sh
(techlab) dletizia@ovh vpc_openstack-base % ./scripts/oscVPC-deployAllBastions.sh
```
### Deploy one by one
#### 1-AZ
##### GRA (GRA11)
```sh
(techlab) dletizia@ovh vpc_openstack-base % ./scripts/oscVPC-deployBastion-gra.sh
```
##### LIM (DE1)
```sh
(techlab) dletizia@ovh vpc_openstack-base % ./scripts/oscVPC-deployBastion-lim.sh
```
### 3-AZ
#### PAR (EU-WEST-PAR)
```sh
(techlab) dletizia@ovh vpc_openstack-base % ./scripts/oscVPC-deployBastion-par.sh
```
#### MIL (EU-WEST-MIL)
> Milan 3az region is not active yet and it is expected to be only released in GA after the Summer
```sh
(techlab) dletizia@ovh vpc_openstack-base % ./scripts/oscVPC-deployBastion-mil.sh
```

## Verifichiamo la messa in opera

[L3 Services](https://help.ovhcloud.com/csm/it-public-cloud-network-concepts?id=kb_article_view&sysparm_article=KB0050142#private-mode-the-instance-remains-private-unless-a-floating-ip-or-a-load-balancer-is-attached)

# Security Group (TODO)

[TODO](https://help.ovhcloud.com/csm/it-public-cloud-compute-firewall-security?id=kb_article_view&sysparm_article=KB0051172)

# Architettura (TODO)

![OS Security Groups](images/ovhTechlabs-PublicCloud_Deployment_Modes-v0.1-lim-1az.drawio.png)