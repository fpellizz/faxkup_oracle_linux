# README #

### Simple script to backup schemas from Oracle DB and save them on aws S3 ###

* Quick summary
This is a simple bash script, who gets a list of Oracle schemas and backup them (using datapump), then tar and gzip every dumpfile and finally push the archive (or the archives) on an aws S3 bucket. 

* Version 1.0

### Dependencies ###

> aws-cli 
>
> python (2.7 or 3.4)

### Setup ###

Download the repository from the bitbucket download page, then unzip it inside a folder
> $ unzip -d /opt/faxkup archive.zip

or clone this repository

> $ mkdir -p /opt/faxkup
>
> $ cd /opt/faxkup
>
> $ git clone user:password@repository.url

you can use a different  directory, **this script MUST run as ROOT**

### Configuration ###
You have to configure two different file:

 1. faxkup.config
 2. schemas.list

#### faxkup.config ####

> TIMESTAMP=$(date +%Y-%m-%d)
> 
> CURRENT_DIR=$(pwd)
> 
> ORACLE_SO_USER="oracle_user"
> 
> ORACLE_DB_SYSTEM_USER="database_system_user" (tipically: system)
> 
> ORACLE_DB_SYSTEM_PASSWORD="database_system_user_password"
> 
> BACKUP_SCHEMAS_LIST=$CURRENT_DIR/schemas.list
> 
> ORACLE_DATA_PUMP_DIR=/path/to/data/pump/dir (tipically: /opt/oracle/admin/dbname/dpdump)
> 
> ORACLE_BACKUP_DIR="data_pump_dir"
> 
> AWS_ACCESS_KEY_ID="AWS-ACCESS-KEY"
> 
> AWS_SECRET_ACCESS_KEY="AWS-SECRET-ACCESS-KEY"
> 
> AWS_DEFAULT_REGION="AWS-REGION"
> 
> AWS_S3_BUCKET="bucket_name"
> 
> AWS_S3_BUCKET_FOLDER="folder_name" (if needed)
> 
> BACKUP_MODE="compact" (backup mode: compact/single)
> 
> SNS_ARN="AWS-SNS-ARN"
> 
> LOG_PATH=$CURRENT_DIR 
> 
> SNS_MESSAGE="" (notification message, remember to configure it!)
> 
> LOG_FILE=faxkup.log


BACKUP_MODE:
	

 - **compact**:
	In **compact** mode, the backup script will tar and gzip all the single datapump (already compressed) into one huge archive and this archive will be pushed on S3 bucket.

 - **single**:
	In **single** mode, the backup script push every single file into the S3 bucket .

#### schemas.lis ####

> ORACLE_SCHEMA_1
>
> ORACLE_SCHEMA_2
>
> ORACLE_SCHEMA_3
>
> [new line]

**this file MUST have an empty "new line" at the end of the file**


### Running ###
To run the faxkup backup, simply run faxkup.sh script.

>\# cd /opt/faxkup
>
> \# chmod +x ./faxkup.sh
>
> \# ./faxkup.sh

### Logging ###
Each time this script runs, write a log of his activities, **faxkup.log**. 
This log is located into the faxkup home directory, tipically /opt/faxkup.
The log is very easy ro read.
