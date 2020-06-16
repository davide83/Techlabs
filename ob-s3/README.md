# Webinar Live DEMO

## OVHcloud Object Storage by S3 compatible API


### - OVHcloud Public Cloud

***Requirements:*** 
> Have a Public Cloud project active, if not [create new one!](https://www.ovh.com/auth?onsuccess=https%3A%2F%2Fwww.ovh.com%2Fmanager%2Fpublic-cloud%2F%23%2Fpci%2Fprojects%2Fonboarding&ovhSubsidiary=IT)

***Steps to follow on the OVHcloud Control Panel:***
1. [Create a new Container of object](https://docs.ovh.com/fr/public-cloud/creer-un-conteneur-dobjets/)
    1. Select a Datacenter (Region) of your choose
        1. i.e. `Strasbourg (sbg)`
    2. Select the Container's type
        1. i.e `Public`
    3. Set a NAME following the [rules for Bucket Naming](https://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html)
        1. i.e. `webinar-s3-api-test`
    4. (Optional) [Increasing your Public Cloud quota](https://docs.ovh.com/gb/en/public-cloud/increase-public-cloud-quota/)
2. Create a new [OpenStack's User](https://docs.ovh.com/gb/en/public-cloud/creation-and-deletion-of-openstack-user/)
    1. Create a new User
        1. i.e. `webinar`
    2. Set *ObjectStore operator* as Role
    3. Download the OpenStack's RC file selecting the Datacenter that you choose


### - Local computer

***Requirements:***
> Have *Python* installed, if not install the Python interpreter for your OS!

***[Steps to follow on your local machine](https://docs.ovh.com/gb/en/public-cloud/getting_started_with_the_swift_S3_API/):***
1. Install OpenStack and AWS clients if needed
    ```sh
    user@host:~$ pip install python-openstackclient awscli awscli-plugin-endpoint
    ```
2. Set the OpenStack environment variables
    ```sh
    user@host:~$ source <user_name>-openrc.sh
    Please enter your OpenStack Password for project <project_name> as user <user_name>:
    ```
3. Create EC2 credentials
    ```sh
    user@host:~$ openstack ec2 credentials create
    +------------+--------------------------------------------------------------------------------------------------------------------------------------------+
    | Field      | Value                                                                                                                                      |
    +------------+--------------------------------------------------------------------------------------------------------------------------------------------+
    | access     | 5blablablablablablablablablab3d3                                                                                                           |
    | links      | {'self': 'https://auth.cloud.ovh.net:35357/v3/users/d74d05blablablablablablabla0df61/credentials/OS-EC2/5blablablablablablablablablab3d3'} |
    | project_id | 20e12blablablablablablablablabla                                                                                                           |
    | secret     | 925d5blablablablablablablablabla                                                                                                           |
    | trust_id   | None                                                                                                                                       |
    | user_id    | d74d05blablablablablablabla0df61                                                                                                           |
    +------------+--------------------------------------------------------------------------------------------------------------------------------------------+
    ```
4. Configure aws client
    1. Create awscli config file if needed
        ```sh
        user@host:~$ mkdir -p ~/.aws && touch ~/.aws/config
        ```
    2. Edit the config file as following
        ```sh
        user@host:~$ cat ~/.aws/config
        [plugins]
        endpoint = awscli_plugin_endpoint

        [profile webinar]
        aws_access_key_id = <access fetched in previous step>
        aws_secret_access_key = <secret fetched in previous step>
        region = <public cloud region in lower case>
        s3 =
        endpoint_url = https://s3.<public cloud region>.cloud.ovh.net
        signature_version = s3v4
        addressing_style = virtual
        s3api =
        endpoint_url = https://s3.<public cloud region>.cloud.ovh.net
        ```

### - Time to play

#### ***Using aws client:***
1. List buckets (containers):
    ```sh
    user@host:~$ aws --profile webinar s3 ls
    ```
2. Create a new bucket:
    ```sh
    user@host:~$ aws --profile webinar s3 mb s3://bucket
    ```
3. Upload a local file to a container (bucket):
    ```sh
    user@host:~$ aws --profile webinar s3 cp README.md s3://bucket/README.md
    ```
4. Download an object from a container (bucket):
    ```sh
    user@host:~$ aws --profile webinar s3 cp s3://bucket/README.md downloaded_README.md
    ```
5. Delete an object from a container (bucket):
    ```sh
    user@host:~$ aws --profile webinar s3 rm s3://bucket/README.md
    ```
6. Delete a container (bucket):
    ```sh
    user@host:~$ aws --profile webinar s3 rb s3://bucket
    ```

#### ***Using our custom script:***
TBD

#### ***Plik (wetransfer like):***
[How to use Plik S3 Data backend with OVHcloud Object Storage](plik-object-storage-s3.md)

#### ***Veeam Backup & Replication:***
[How to use Veeam Backup & Replication with OVHcloud Object Storage](veeam-object-storage-s3.md)
