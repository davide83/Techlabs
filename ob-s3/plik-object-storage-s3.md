# Using Plik with OVHcloud Object Storage

## Plik Overview
[Plik](https://github.com/root-gg/plik) Plik is a scalable & friendly temporary file upload system ( wetransfer like ) in golang.

Recently, the Plik's team released the version `1.3-RC1` that include a native Simple Storage Service (`S3`) as `Data backend`.

> Requirements
> - You have a physical or virtual machine with [Dokku](http://dokku.viewdocs.io/dokku/) installed
> - You have configured an OVhcloud Object Storage container (Bucket)

## Deploy Plik on Dokku PaaS

### Configuring Plik on Dokku node
1. SSH on your server with an user that has `root` privilege.
    ```sh
    user@host:~$ ssh root@<your-server-hostname-or-ip>
    ```
2. Create a new App `plik-s3-webinar`.
    ```sh
    root@host:~# dokku apps:create plik-s3-webinar
    ```
3. Create a new DB `plik-s3-webinar-db`.
    1. > IMPORTANT: Plik supports only SQLite or Postgres as Metadata backend
       > If needed install the postgres plugin
       > ```sh
       > root@host:~# sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git
       > ```
    2. ```sh
        root@host:~# dokku postgres:create plik-s3-webinar-db
        ```
    3. Safely store the *Dsn* parameter as we need it when we will configure the Plik configuration file (`plikd.cfg`)
        1. The `Dsn` string should be like this: `postgres://<user>:<user-password>@<host>:<port>/<dbname>`

### Configuring Plik on local machine

1. Create a new folder `my-plik-s3` on your local Workspace
    ```sh
    user@host:~$ cd /path/to/your/local/workspace && mkdir -p my-plik-s3 && cd my-plik-s3
    ```
2. Create a new `Dockerfile` as the following and put it inside the create folder
    ```Dockerfile
    FROM rootgg/plik:1.3-RC1
    
    WORKDIR /home/plik/server

    COPY --chown=1000:1000 plikd.cfg /home/plik/server/

    EXPOSE 8080

    USER plik

    CMD ./plikd

    ```
3. Create the Plik config file as this
    ```sh
    user@host:~$ cat plikd.cfg 
    #####
    ##
    #  Plik - Configuration File
    #
    ##
    #  S3 as Data backend
    #  Postgres as Metadata backend
    #  Dokku as Deployment PaaS
    #

    Debug               = false         # Enable debug mode
    DebugRequests       = false         # Log HTTP request and responses
    ListenPort          = 80            # Port the HTTP server will listen on
    ListenAddress       = "0.0.0.0"     # Address the HTTP server will bind on
    Path                = ""            # HTTP root path

    MaxFileSize         = 10737418240   # 10GB
    MaxFilePerUpload    = 1000

    DefaultTTL          = 2592000       # 30 days
    MaxTTL              = 2592000       # -1 => No limit
    OneShot             = true          # Allow users to make one shot uploads
    Removable           = true          # allow users to make removable uploads
    Stream              = true          # Enable stream mode
    ProtectedByPassword = true          # Allow users to protect the download with a password

    SslEnabled          = false         # Enable SSL
    SslCert             = "plik.crt"    # Path to your certificate file
    SslKey              = "plik.key"    # Path to your certificate private key file
    NoWebInterface      = false         # Disable web user interface
    DownloadDomain      = ""            # Enforce download domain ( ex : https://dl.plik.root.gg ) ( necessary for quick upload to work )
    EnhancedWebSecurity = true          # Enable additional security headers ( X-Content-Type-Options, X-XSS-Protection, X-Frame-Options, Content-Security-Policy, Secure Cookies, ... )

    SourceIpHeader      = ""            # If behind reverse proxy ( ex : X-FORWARDED-FOR )
    UploadWhitelist     = []            # Restrict upload ans user creation to one or more IP range ( CIDR notation, /32 can be omitted )

    Authentication      = false          # Enable authentication
    NoAnonymousUploads  = false         # Prevent unauthenticated users to upload files
    GoogleApiClientID   = ""            # Google api client ID
    GoogleApiSecret     = ""            # Google api client secret
    GoogleValidDomains  = []            # List of acceptable email domains for users
    OvhApiKey           = ""            # OVH api application key
    OvhApiSecret        = ""            # OVH api application secret
    OvhApiEndpoint      = ""            # OVH api endpoint to use. Defaults to https://eu.api.ovh.com/1.0

    #   Data backend configuration
    #
    #   Example using File :
    #
    #   DataBackend = "file"
    #   [DataBackendConfig]
    #       Directory = "files"
    #
    #   Example using OpenStack Swift :
    #
    #   DataBackend = "swift"
    #   [DataBackendConfig]
    #       Container = "plik"
    #       AuthUrl = "https://auth.swiftauthapi.xxx/v2.0/"
    #       UserName = "user@tld.net"
    #       ApiKey = "xxxxxxxxxxxxxxxx"
    #       Domain = "domain"  // Name of the domain (v3 auth only)
    #       Tenant = "tenant"  // Name of the tenant (v2 auth only)
    #
    #       Please refer to https://github.com/ncw/swift for all
    #       connection settings available (v1/v2/v3)
    #
    #
    #   DataBackend  = "s3"
    #   [DataBackendConfig]
    #       Endpoint = "127.0.0.1:9000"
    #       AccessKeyID = "access_key_id"
    #       SecretAccessKey = "access_key_secret"
    #       Bucket = "plik"
    #       Location = "us-east-1"
    #       UseSSL = true
    #       PartSize = 33554432 // Chunk size when file size is not known ( default to 32MB )

    DataBackend  = "s3"
    [DataBackendConfig]
        Endpoint = "s3.<public cloud region>.cloud.ovh.net"
        AccessKeyID = "<access fetched in previous step>"
        SecretAccessKey = "<secret fetched in previous step>"
        Bucket = "<container name already created>" 
        Location = "<public cloud region in lower case>"
        UseSSL = true
        PartSize = 33554432 # Chunk size when file size is not known ( default to 32MB )

    #   Metadata backend configuration
    #
    #   Supported drivers : sqlite3 / postgres
    #   Connection string : See http://gorm.io/docs/connecting_to_the_database.html
    #
    [MetadataBackendConfig]
        Driver = "postgres"
        ConnectionString = "host=<host> port=<port> user=<user> dbname=<dbname> password=<user-password>"
        Debug = false # Log SQL requests

    ```

### Deply Plik on remote Dokku server
***Requirements:***
> Have *Git* installed, if not install Git tools for your OS!

1. Initialize the folder as Git repository
    ```sh
    user@host:~$ git init
    ```
2. Add Dokku server as remote Git repository
    ```sh
    user@host:~$ git remote add dokku dokku@<your-server-hostname-or-ip>:<dokku-app-names>
    ```
3. Commit change to git
    ```sh
    user@host:~$ git add . && git commit -m "push on prod"
    ```
4. Push change to remote
    ```sh
    user@host:~$ git push dokku master
    ```
5. Enjoy with your self-hosted Plik (wetransfer like) platform using S3 compatible API as Data backend and Postgres as Metadata backend