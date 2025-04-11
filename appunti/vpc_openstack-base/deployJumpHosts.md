Deploy JumpHosts
===

Riversiamo il contenuto del file **ovhrc** nella shell corrente ed esportiamo la variabile _OS_REGION_NAME_ name quando necessario.

```bash
source utils/ovhrc && export OS_REGION_NAME=DE1
```

# Deploy Bastions

## OpenStack Keys (TODO)

TODO
```sh
(techlab) dletizia@ovh vpc_openstack-base % ./scripts/oscVPC-deployKeys.sh
```

## SPAWN VM Instances w/ Floating IP

```sh
(techlab) dletizia@ovh vpc_openstack-base % ./scripts/oscVPC-deployBastions.sh
```

```sh
openstack server create \
  --description "Bastion Host <vpc-net-name> <vpc-region-name>" \
  --flavor c3-4 \
  --image "Ubuntu 22.04" \
  --network <vpc-network-id> \
  --key-name <vpc-sshkey-name> \
  <vpc-bastion-name>
```

[dg](https://help.ovhcloud.com/csm/en-public-cloud-compute-launch-script-at-instance-creation?id=kb_article_view&sysparm_article=KB0050912)

### Extra
https://docs.openstack.org/nova/train/user/metadata.html#metadata-openstack-format

## FINE

TODO

# Come configurare un Bastion server (SSH Jump)

Un server SSH Jump tradizionale e che utilizza OpenSSH.

Il vantaggio di questo metodo è che i server dispongono già di OpenSSH preinstallato, semplice da installare e configurare, gratuito, open source ed è un _daemon_ Linux a binario singolo.

[ref. Teleport](https://goteleport.com/blog/ssh-jump-server/)

## Cos’è un SSH Jump server?

Un server SSH jump è un normale server Linux, accessibile da Internet, che viene utilizzato come gateway per accedere ad altre macchine Linux su una rete privata utilizzando il protocollo SSH. A volte un server SSH Jump viene anche chiamato "**jump host**" o "**bastion host**". Lo scopo di un server SSH Jump è essere l’unico gateway per l’accesso all’infrastruttura, riducendo la dimensione di qualsiasi potenziale superficie di attacco. Disporre di un access point SSH dedicato facilita inoltre la creazione di un log di controllo aggregato di tutte le connessioni SSH.

### Perché non chiamarlo SSH Proxy?

In parte per motivi storici. Nei primi giorni di SSH, gli utenti dovevano passare a un nodo di collegamento e da lì digitare nuovamente ssh per passare al nodo di destinazione. Oggi, questa operazione viene eseguita automaticamente utilizzando l'opzione ProxyJump.

## Come configurare un server SSH Jump

Una buona pratica di sicurezza è avere un server dedicato SSH Jump, cioè non ospitare nessun altro software pubblicamente accessibile su di esso. Non è inoltre consigliabile consentire agli utenti di accedere direttamente a un server di collegamento. Ecco il perchè di alcune motivazioni:

- Aggiornamento involontario della configurazione del server di collegamento.
- Utilizzare il server di collegamento per altre operazioni.
- Effettuare copie delle chiavi utilizzate per accedere ai server di destinazione.

> Inoltre, è consigliato di cambiare la porta TCP predefinita sul server SSH Jump da 22 a qualcos’altro.

Passiamo ora alla configurazione di un server SSH Jump con OpenSSH essendo il più comune.

### Ma prima di tutto ...

Facciamo alcuni assunti di base per gli esempi usati qui sotto:

Il dominio organizzazione di esempio è example.com - Il nome DNS del server di collegamento sarà proxy.example.com

Partiamo dal presupposto che proxy.example.com sia l'unica macchina accessibile da Internet.

## OpenSSH

Questo server SSH viene fornito di default con la maggior parte delle distribuzioni Linux e le possibilità di averlo già installato sono quasi del 100%. Se il server è accessibile tramite _proxy.example.com_, è possibile accedere ad altri server dietro lo stesso confine **NAT** tramite il flag della riga di comando _-J_, ad esempio sul client: 

`$ ssh -J proxy.example.com 10.2.2.1`

Nell'esempio precedente, il server di collegamento viene utilizzato per accedere a un altro host su un **VPC** con indirizzo 10.2.2.1. Finora, tutto ciò sembra piuttosto semplice.

Per evitare di digitare sempre `-J proxy.example.com`, è possibile aggiornare la [configurazione SSH del client](https://goteleport.com/blog/ssh-config/) in `~/.ssh/config` con le seguenti opzioni:

```bash
Host 10.2.2.*
ProxyJump proxy.example.com
```

Ora, quando un utente digita `ssh 10.2.2.1` il suo client SSH non tenterà nemmeno di risolvere 10.2.2.1 localmente, ma stabilirà una connessione a proxy.example.com che lo inoltrerà alla 10.2.2.1 all'interno del suo VPC.

A questo punto è necessario rendere più sicura la configurazione del server disabilitando le sessioni SSH interattive sul server di collegamento per i normali utenti, ma lasciandola attiva per gli amministratori. Per farlo, aggiorna la configurazione sshd, solitamente in /etc/ssh/sshd_config con quanto segue:

### Do not let SSH clients do nothing except to be forward to the destination:

```bash
PermitTTY no
X11Inoltro no
PermitTunnel no
GatewayPorts no
ForceCommand /sbin/nologin
```

L'esempio qui sopra funzionerà per Debian e i suoi derivati, ti consigliamo di verificare l'esistenza di /sbin/nologin.

Questo funzionerà finché il server di collegamento dispone di account per tutti gli utenti SSH, il che è scomodo. In alternativa, è consigliabile creare un account utente separato sul server di collegamento dedicato ai "jumping users". Chiamiamolo jumpuser e aggiorna la configurazione:

```bash
Utente Jump User corrispondente
PermitTTY no
X11Inoltro no
PermitTunnel no
GatewayPorts no
ForceCommand /usr/sbin/nologin
```

Inoltre, gli utenti dovranno aggiornare la configurazione SSH del proprio client con:

```bash
Host 10.2.2.*
ProxyJump jumpuser@proxy.example.com
```

Per maggiori informazioni su come ottimizzare la configurazione dei collegamenti SSH in base alla situazione specifica, consultare `man ssh_config` e `man sshd_config`.

Ovviamente, la configurazione di cui sopra funziona solo quando le chiavi SSH pubbliche sono correttamente distribuite non solo tra i client e il server di collegamento, ma anche tra i client e i server di destinazione.

## Conclusioni

In questi appunti abbiamo spiegato come creare un server SSH Jump utilizzando OpenSSH.

`\!/ Utilizza OpenSSH se il numero di server o utenti nell'organizzazione è ridotto ed è necessario installare rapidamente un host di collegamento e non si ha molto tempo per una protezione avanzata \!/`

### Protezione avanzata

[E' buona pratica proteggere i Bastion host](https://goteleport.com/blog/security-hardening-ssh-bastion-best-practices/), come il rinforzamento del sistema operativo dei server, dell’autenticazione e delle operazioni crittografiche OpenSSH e l’implementazione del Bastion con alta disponibilità.

#### The Bastion by OVHcloud

![The Bastion](images/ovhTheBastion-github.png)

I bastioni sono un cluster di macchine utilizzate come unico punto di ingresso dai team operativi (ad esempio sysadmin, sviluppatori, amministratori di database, ecc...) per connettersi in modo sicuro a dispositivi (server, macchine virtuali, istanze Cloud, apparecchiature di rete, ecc...), solitamente utilizzando ssh.

[**The Bastion**](https://github.com/ovh/the-bastion) fornisce meccanismi di autenticazione, autorizzazione, tracciabilità e auditing per l’intera infrastruttura.

Essendo tra gli utenti e la propria infrastruttura, _The Bastion_ aggiunge un livello di astrazione intermedio in modo che la propria infrastruttura non abbia bisogno di conoscere individualmente i membri del team operativo.

Ogni membro del team dispone di un account personale su **The Bastion** e può essere membro di uno o più gruppi di bastioni che possono dare loro accesso a una o più infrastrutture. I dispositivi dell’infrastruttura devono solo conoscere e fidarsi dei gruppi di bastioni di cui possono fare parte.

Il RBAC di Bastion, con una classificazione precisa, permette di delegare alcune responsabilità a qualsiasi account, a livello di gruppo o di bastione, inclusi gli account che potrebbero essere utilizzati dalla vostra automazione per gestire, ad esempio, il ciclo di vita degli account (collegati al vostro sistema di gestione delle risorse umane, al vostro LDAP o AD), garantire che l'ACL di un gruppo sia aggiornato (collegato al vostro CMDB), ecc. I processi automatizzati sono facili da implementare tramite l’API JSON su SSH.
