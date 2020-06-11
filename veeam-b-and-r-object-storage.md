# Using Veeam Backup & Replication with OVHcloud Object Storage

## Veeam Overview
[Veeam Backup & Replication](https://www.veeam.com/vm-backup-recovery-replication-software.html) is a backup platform that provides backup, restore and replication functionality for virtual machines, physical servers and workstations as well as cloud-based workloads.

A native Simple Storage Service (S3) interface for Veeam Backup & Replication is available for more than one year. It allows to push backups to a S3 compatible service to maximize backup capacity.

> Requirements
> - You have a physical machine or cluster running VMware vSphere or MS Hyper-V
> - You have an intermediate instance running Veeam Backup & Replication platform
> - You have configured an OVhcloud Object Storage container (Bucket)

> Important: A Veeam “Enterprise” or “Enterprise Plus” license is required in order to configure the Scale out Repository feature which is required for Object Storage. In case you need a license you could evaluate [OVHcloud Veeam Enterprise] (https://www.ovh.com/world/storage-solutions/veeam-enterprise.xml)

## Configuring Veeam Backup & Replication

### Configuring an Object Storage Repository
1. Start the `Veeam Console` and `Connect` with your credential.
2. Once logged into the Veeam console, click on `Backup Infrastructure`.
3. Click on `Backup Repositories` to enter the backup repository settings, then click on `Add Repository` to add the Object Storage bucket as repository.
4. Choose `Object Storage` and click on `S3 Compatible`.
5. The setup wizard for the repository appears, provide a *name* and *description* information for it, then click on `Next`.
6. Click on `Add` to enter the *Access* and *Secret* keys related to the bucket.
7. Provide the *Service Point* and the *Region* of your bucket
    1. The *Service point* should be: `s3.<public cloud region>.cloud.ovh.net` or `s3.<public cloud region>.cloud.ovh.us` if you are an OVH US customer only.
    2. The *Region* should be: `<public cloud region in lower case>`.
    > For a container (bucket), located in the Strasbourg region, the service point is `s3.sbg.cloud.ovh.net` and the region is `sbg`
    3. Click on `Next`.
8. Veeam will connect to the S3 compatible infrastructure and download the list of Object Storage Buckets. Choose the bucket to be used with Veeam from the drop-down list, click on `Browse` and create and select the folder for storing backups. Then click on `Next`.
    > If you want it's possible to set a limit for Object Storage consumption.
9. Verify all settings in the summary before clicking on `Finish`.

## Final steps
> ### Known Limits 
> Object storage based repositories can only used for Capacity Tier of scale-out backup repositories, backing up directly to object storage is not currently supported by Veeam. 

As Veeam cannot currently push backups directly to S3, this means that we may:
1. Configure and use a local/net backup repository following the Wizard.
2. Configure a Scale-out Repository using our alternative backup repository following the Wizard.
3. Add a vSphere/Hyper-V Hypervisor in Veeam.
4. Configure a Backup Job as usual.
5. After the Job is done, log-in into your OVHcloud Control Panel and verify your Bucket. Several files and folders created by the Veeam platform will be visible.