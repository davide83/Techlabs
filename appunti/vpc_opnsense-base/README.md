Configurazione del cluster OPNsense HA
===

Il firewall open source gratuito [OPNsense](https://opnsense.org/) può essere configurato come firewall ridondante con failover automatico. In questo documento viene illustrato come configurare un cluster HA con questo tipo di firewall con due macchine firewall (in questo caso due **VM Instance _C3-4_**).

Basato sul solido [_OPNsense HA Cluster configuration_](https://www.thomas-krenn.com/en/wiki/OPNsense_HA_Cluster_configuration) e ispirato da:
- [_Securing your OVHcloud infrastructure with Stormshield Network Security_](https://help.ovhcloud.com/csm/en-public-cloud-network-stormshield-vrack?id=kb_article_view&sysparm_article=KB0065106)
- [_How to Configure High Availability on OPNsense_](https://www.zenarmor.com/docs/network-security-tutorials/how-to-configure-ha-on-opnsense)

# Requisiti

Un firewall OPNsense ridondato richiede:
- Due firewall, ognuno con almeno tre porte di rete.
- WAN: uplink con almeno tre indirizzi IP disponibili (un indirizzo IP fisso per ogni Firewall 1 e Firewall 2, oltre a un indirizzo IP virtuale aggiuntivo per il Firewall Master).
- LAN: tre indirizzi IP gratuiti nella LAN (un indirizzo IP fisso per ogni Firewall 1 e Firewall 2 e un indirizzo IP virtuale aggiuntivo per il Firewall Master).

Se i due nodi cluster OPNsense sono in esecuzione in macchine virtuali, è necessario consentire alle macchine virtuali di modificare gli indirizzi MAC. Questa operazione è necessaria per l'utilizzo del protocollo CARP (Common Address Redundancy Protocol). L'impostazione corrispondente all'ambiente virtuale openstack sarà quella di disabilitare il security port. Protezione attiva (default per openstack vanilla) contro lo _spoofing_ degli indirizzi MAC (più dettagli [qui](https://help.ovhcloud.com/csm/en-public-cloud-compute-firewall-security?id=kb_article_view&sysparm_article=KB0051166)).

# Nozioni di base

In un firewall OPNsense ridondato vengono utilizzate le tecnologie seguenti:
- Common Address Redundancy Protocol ([CARP](https://de.wikipedia.org/wiki/Common_Address_Redundancy_Protocol))': Protocollo per la fornitura di indirizzi IP ad alta disponibilità
    - Utilizza il protocollo IP 112 (come VRRP).
    - Utilizza pacchetti multicast per comunicare le informazioni sullo stato corrente ad altri computer partecipanti nel cluster.
- [pfsync](OPNsense HA Cluster configuration): Protocollo per la replica delle informazioni di stato delle singole connessioni di rete (sincronizzazione delle tabelle di stato).
    - Nota: affinché le informazioni sullo stato vengano applicate correttamente a entrambi i firewall, è necessario che entrambi utilizzino gli stessi nomi di interfaccia per le stesse reti. Ad esempio, se la rete interna (LAN) sul firewall 1 è connessa tramite l'interfaccia vtnet0, anche vtnet0 deve essere assegnata alla LAN sul firewall 2. Se sono presenti due diversi firewall con schede di rete diverse (e quindi nomi di interfaccia), e non potendo configurare LAG come soluzione alternativa, mitigheremo via codice l'ordine di assegnazione delle interfaccie, ottenendo sempre e a priori : vtnet0=lan , vtnet1=wan , vtnet2=ha [ vtnet3=dmz , vtnet4=vpn ]
    - Per pfSync si consiglia di utilizzare un'interfaccia dedicata su entrambi i firewall. Questo aumenta la sicurezza (iniezione di stato) e le prestazioni.
- Sincronizzazione XMLRPC: sincronizzazione della configurazione del firewall.

# Configurazione

> Suggerimento: prima di configurare un nuovo firewall, configurare la rete del cluster. Dopo aver configurato il cluster HA, è necessario configurare ulteriori configurazioni del firewall (regole del firewall, servizi, ecc.). Questa procedura riduce le possibili sorgenti di errore.

Per configurare un firewall OPNsense ridondante, [segui questi passaggi](https://docs.opnsense.org/manual/how-tos/carp.html):
1. Installazione di OPNsense su entrambi i nodi firewall.
2. Configurazione degli indirizzi IP statici su Firewall 1 e Firewall 2. Se si utilizza solo IPv4, si consiglia di disattivare IPv6 su entrambi i firewall. In questo esempio utilizziamo i seguenti indirizzi IP:
    - vtnet0 (LAN): 192.168.42.41/24 (Firewall 1); 192.168.42.42/24 (Firewall 2)
    - vtnet1 (WAN): 57.130.6.177/29 (Firewall 1); 57.130.6.178/29 (Firewall 2)
    - vtnet2 (pfSync): 192.168.46.41/30 (Firewall 1); 192.168.46.42/30 (Firewall 2). I dettagli sulla configurazione di questa interfaccia di rete aggiuntiva sono documentati nell'articolo [OPNsense add interface](https://www.thomas-krenn.com/en/wiki/OPNsense_add_interface).
3. Disattivare il server DHCP in entrambi i firewall (in `Services ‣ DHCPv4 ‣ [LAN]`).
4. Crea regole firewall su entrambi i firewall. In `Firewall ‣ Rules` sono necessarie le regole seguenti per le tre interfacce:
    - LAN: consenti pacchetti CARP (selezionare `Protocol: CARP`)
    - WAN: consenti pacchetti CARP (selezionare `Protocol: CARP`)
    - PFSYNC: poiché si tratta di una connessione diretta via cavo, consentire qualsiasi traffico di rete.
5. Configura IP virtuali:
    - Su Firewall 1 (Master) in `Interfaces ‣ Virtuali IPs ‣ Settings` crea un nuovo IP WAN virtuale con i seguenti parametri cliccando su + Aggiungi:
        - Modalità: CARP
        - Interfaccia: WAN
        - Indirizzo: 57.130.6.181/29
        - Password virtuale: usa una password casuale di 30 caratteri. `tr -dc A-Za-z0-9_ < /dev/urandom | head -c 30 | xargs`
        - Gruppo VHID: 1
        - Frequenza Advertising:  Base 1 / Skew 0
        - Descrizione: Virtual WAN IP
    - Crea un nuovo IP LAN virtuale con i seguenti parametri sul Firewall 1 (Master) cliccando su + Aggiungi:
        - Modalità: CARP
        - Interfaccia: LAN
        - Indirizzo: 192.168.42.1/24
        - Password virtuale: usa una password casuale di 30 caratteri.
        - VHID Group: 3 (questo numero viene utilizzato come ultimo ottetto dell'indirizzo MAC per l'indirizzo IP virtuale, in questo esempio l'indirizzo MAC è quindi 00:00:5e:00:01:[03](https://tools.ietf.org/html/rfc5798#section-7.3))
        - Frequenza Advertising: Base 1 / Skew 0
        - Descrizione: Virtual LAN IP
6. Configura NAT in uscita. In Firewall, selezionare l'opzione Generazione manuale regole NAT in uscita e creare una nuova regola facendo clic su + Aggiungi:
    - Interfaccia: WAN
    - Indirizzo di origine: LAN net
    - Traduzione/destinazione: 57.130.6.181 (IP WAN virtuale)
7. Optionally configure DHCP server. On both firewalls under `Services ‣ DHCPv4 ‣ [LAN]`, select the following parameters:
    - Server DNS: 192.168.42.1 (corrisponde all'IP LAN Virtuale)
    - Gateway: 192.168.42.1 (corrisponde all'IP LAN Virtuale)
    - IP peer failover: 192.168.42.42 (IP dell'altro firewall), su firewall 2 set 192.168.42.41 (IP del primo firewall)
8. Configurare pfSync e la sincronizzazione HA (xmlrpc) su Firewall 1. In Impostazioni High Availability di sistema, selezionare le impostazioni seguenti:
    -  Sincronizza stati: ✔
    - Interfaccia di sincronizzazione: PFSYNC
    - Synchronize Peer IP: 192.168.46.42 (qui utilizzare l'indirizzo IP dell'interfaccia PFSYNC del Firewall 2)
    - Sincronizza configurazione con IP: 192.168.46.42
    - Nome utente sistema remoto: root
    - Password del sistema remoto: (password del firewall 2)
    - Selezionare i servizi da sincronizzare. In questo esempio:
        - Dashboard: ✔
        - Regole firewall: ✔
        - Alias: ✔
        - NAT: ✔
        - DHCPD: ✔
        - IP virtuali: ✔
9. Configura pfSync su Firewall 2. In Impostazioni High Availability di sistema, selezionare le impostazioni seguenti:
    - Sincronizza stati: ✔
    - [Disable preempt](https://www.openbsd.org/faq/pf/carp.html): lascia disattivata l'opzione di anticipo. In questo modo, in caso di malfunzionamento di una singola connessione di rete (ad esempio, connessione WAN dal firewall 1), tutti gli indirizzi IP (WAN e LAN in questo esempio) vengono spostati sul secondo firewall.
    - Interfaccia di sincronizzazione: PFSYNC
    - Synchronize Peer IP: 192.168.46.41 (qui utilizzare l'indirizzo IP dell'interfaccia PFSYNC del Firewall 1)
    - Nota: non configurare la sincronizzazione HA (xmlrpc) sul firewall 2. La configurazione successiva (ad esempio delle regole del firewall, ecc.) viene eseguita esclusivamente sul firewall 1 e quindi sincronizzata con il firewall 2.
10.  Su Firewall 1 nel Dashboard, aggiungi il widget CARP cliccando su + Widget, selezionando CARP e quindi facendo clic su Impostazioni di sicurezza.
11. Infine riavviare entrambi i sistemi.

Nota: se sono configurati servizi aggiuntivi (ad esempio OpenVPN), la sincronizzazione della configurazione deve prima essere attivata in Impostazioni High Availability di Sistema. Durante la configurazione del servizio, è necessario selezionare l'IP WAN virtuale come interfaccia del servizio.

# EXTRA

vedi [DEV.md](DEV.md) per i dettagli degli