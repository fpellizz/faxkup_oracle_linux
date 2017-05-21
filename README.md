# README #

### Simple script to backup schemas from Oracle DB and save them on aws S3 ###

* Quick summary
This is a simple bash script, who get a list of Oracle schemas and backup them (using datapump), then tar and gzip every dumpfile and finally push the archive (or the archives) on an aws S3 bucket. 
Now it is possible to run a "prebackup" and a "postbackup" scripts. 
With these scripts you can perrform any action before and after the oracle "core" backup.
* Version 1.1

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
> $ git clone https://github.com/fpellizz/faxkup_oracle_linux.git

you can use a different  directory, **this script MUST run as ROOT**

### Configuration ###
You have to configure two different file:

 1. faxkup.config
 2. schemas.list

#### faxkup.config ####

> HOME_DIR=/oath/to/home/directory (tipically: /op/faxkup)
> 
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

 - **full**:
	In **full** mode, the backup script will perform a backup of the whole database and push it into the S3 bucket .

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

You can schedule the faxkup using crontab, **always as root**

>\# crontab -e
>
>\# 59 23 * * * /bin/bash /opt/faxkup/faxkup.sh > /opt/faxkup/faxkup.out 2>&1
>

without the output redirection sometimes you can have some strange behaviuor like unexpected end of backup script without any error


### Logging ###
Each time this script runs, write a log of his activities, **faxkup.log**. 
This log is located into the faxkup home directory, tipically /opt/faxkup.
The log is very easy ro read.

### OPTIONAL ###
You can create your prebackup and postbackup script.
In **prebackup** script you can tell to the bakcup system to perform a specific action **BEFORE** running backup the oracle schemas of the schema.list file, for example tar a folder and add the tar to the oracle backup.
In **postbackup** script you can tell to the bakcup system to perform a specific action **AFTER** running backup the oracle schemas of the schema.list file, for example send a mail notification in case of errors.

### ISSUE ###
In some case you can have a very misteriuos mistery behaviour when you crontab this backup, I've found a "porkaround" using **screen**. 

>\# crontab -l
>
>\# 59 23 * * * /usr/bin/screen -d -c "/opt/faxkup/faxkup.sh"
>

### TO DO ###
 1. store on local path
 2. backup mode override using switch from command line ./faxbackup.sh -f => full backup
 3. Try to explore "differential" backup
