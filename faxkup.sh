#!/bin/bash

. /opt/faxkup/faxkup.config

function check_log(){
    if [ ! -s $LOG_PATH/$LOG_FILE ];
    then
        echo "####################################################"  > $LOG_PATH/$LOG_FILE
        echo "# Faxkup Setup                                      " >> $LOG_PATH/$LOG_FILE
        echo "# Faxkup the Fax Backup                             " >> $LOG_PATH/$LOG_FILE
        echo "# first run => $TIMESTAMP                           " >> $LOG_PATH/$LOG_FILE
        echo "####################################################" >> $LOG_PATH/$LOG_FILE
        echo ""                                                     >> $LOG_PATH/$LOG_FILE
    fi
}


function write_to_log(){
        check_log
        YEAR=$(date +%Y)
        MONTH=$(date +%m)
        DAY=$(date +%d)
        HOUR=$(date +%H)
        MINUTES=$(date +%M)
        SECONDS=$(date +%S)
        LOG_TIMESTAMP="$YEAR $MONTH $DAY - $HOUR:$MINUTES:$SECONDS"
        echo "$LOG_TIMESTAMP => $LOG_MSG" >> $LOG_PATH/$LOG_FILE
}


function am_i_root(){
    LOG_MSG="Checking user..."
    write_to_log
    who_am_i=$(whoami)
    if [ $who_am_i != "root" ];
    then
        LOG_MSG="You are running faxkup with $who_am_i user, but you need to be ROOT to run properly this backup script."
        write_to_log
        LOG_MSG="Come back when you will be Root. Exit"
        write_to_log
        exit
    else 
        LOG_MSG="user Ok"
        write_to_log
    fi
}


function check_aws_cli(){
    LOG_MSG="Checking aws-cli..."
    write_to_log
    if command -v aws > /dev/null 2>&1 ;
    then
            aws_cli_present=1
            LOG_MSG="aws-cli OK"
            write_to_log
    else
            aws_cli_present=0
            LOG_MSG="aws-cli KO"
            write_to_log
            LOG_MSG="Installing aws-cli..."
            write_to_log
            check_pip
            if [ $pip_present -eq 1 ];
            then
                install_aws_cli_pip
            else
                LOG_MSG="cannot use pip, try to install from binaries..."
                write_to_log                
                install_aws_cli
            fi
            
    fi
}


function check_python(){
    LOG_MSG="Checking Python..."
    write_to_log
    if command -v python > /dev/null 2>&1; 
    then
	python_present=1
        LOG_MSG="Python OK"
        write_to_log
    else
        python_present=0
        LOG_MSG="Python KO"
        write_to_log
    fi
}


function install_aws_cli(){
    LOG_MSG="downloading aws-cli from https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"
    write_to_log   
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
    exit_status=$?
    if [ $exit_status -eq 0 ];
    then 
        echo "download ok..."
        LOG_MSG="download ok"
        write_to_log
    else
        LOG_MSG="Something went wrong during download :( "
        write_to_log
        LOG_MSG="No aws-cli, no backup. QUIT "
        write_to_log
        exit
    fi
    LOG_MSG="unzippinging awscli-bundle.zip ..."
    write_to_log
    unzip awscli-bundle.zip    
    exit_status=$?
    if [ $exit_status -eq 0 ];
    then 
        echo "unzip ok..."
        LOG_MSG="unzip ok"
        write_to_log
    else
        LOG_MSG="Something went wrong during unzipping :( "
        write_to_log
        LOG_MSG="No aws-cli, no backup. QUIT "
        write_to_log
        exit
    fi    
    LOG_MSG="installing aws-cli..."
    write_to_log    
    ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    exit_status=$?
    if [ $exit_status -eq 0 ];
    then 
        echo "installation of aws-cli ok"
        LOG_MSG="installation of aws-cli ok"
        write_to_log
    else
        LOG_MSG="Something went wrong during installation :( "
        write_to_log
        LOG_MSG="No aws-cli, no backup. QUIT "
        write_to_log
        exit
    fi        
    check_aws_cli
}


function check_pip(){
    LOG_MSG="Checking python pip..."
    write_to_log
    if command -v pip > /dev/null 2>&1 ;
    then
        pip_present=1
        LOG_MSG="pip OK"
        write_to_log
    else
        pip_present=0
        LOG_MSG="pip KO"
        write_to_log
        LOG_MSG="Installing pip..."
        write_to_log
        install_pip          
    fi
}


function install_pip(){
    LOG_MSG="installing pip from repository... "
    write_to_log
    yum -y install python-pip
    exit_status=$?
    if [ $exit_status -eq 0 ];
    then
        echo "pip installed"
        LOG_MSG="pip installation ok"
        write_to_log
    else
        LOG_MSG="Something went wrong during installing pip :( "
        write_to_log
        #LOG_MSG="No pip => No aws-cli, no backup. QUIT "
        #write_to_log
        #exit
    fi
}


function install_aws_cli_pip(){
    check_pip
    LOG_MSG="installing aws-cli using pip... "
    write_to_log   
    pip install awscli
    exit_status=$?
    if [ $exit_status -eq 0 ];
    then 
        echo "aws-cli installation (via pip) ok"
        LOG_MSG="aws-cli installation (via pip) ok"
        write_to_log
    else
        LOG_MSG="Something went wrong during aws-cli installation (via pip) :( "
        write_to_log
        LOG_MSG="No aws-cli, no backup. QUIT "
        write_to_log
        exit
    fi
}


function check_prerequisites(){

    check_python
    check_aws_cli
    
    if [ $python_present -eq 1 ] && [ $aws_cli_present -eq 1 ];
    then
        echo "python  => OK"
        echo "aws-cli => OK"
        LOG_MSG="Prerequisites OK... continue to backup"
        write_to_log
    elif [ $python_present -eq 1 ] && [ $aws_cli_present -eq 0 ];
    then
        echo ""
        echo "Cannot find aws-cli, please install it before run backup"
        echo ""
        LOG_MSG="aws-cli is missing... QUIT"
        write_to_log
        exit
    elif [ $python_present -eq 0 ] && [ $aws_cli_present -eq 1 ];
    then
        echo ""
        echo "Cannot find python, please install it before run backup"
        echo ""
        LOG_MSG="Python is missing... QUIT"
        write_to_log
        exit
    else
        echo ""
        echo "Cannot find python and aws-cli, prease install them before run backup"
        echo ""
        LOG_MSG="Python and aws-cli missing... QUIT"
        write_to_log
        exit
    fi
}


function clean_env(){
    LOG_MSG="Cleaning environment..."
    write_to_log    
    cd $CURRENT_DIR
    find . -name "*.error" -exec rm -rf {} \;
    LOG_MSG="Clean terminated..."
    write_to_log
}


function clean(){
    LOG_MSG="Cleaning workspace..."
    write_to_log    
    cd $ORACLE_DATA_PUMP_DIR
    find . -name "*.tar.gz" -exec rm -rf {} \;
    LOG_MSG="Clean terminated..."
    write_to_log
}


function set_aws_env(){
    LOG_MSG="Setting up AWS environment"
    write_to_log
    export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
    export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
}


function sns_notify(){
    LOG_MSG="Sending notification via Amazon SNS..."
    write_to_log
    if [[ -z $MESSAGE ]];
    then
        LOG_MSG="Message body is not configurated, using default"
        write_to_log
        hostname=$(hostname)
        MESSAGE="[[INFO]] Backup server $hostname done. Good job guy PS: please configure this notification"
    fi
    aws sns publish --topic-arn $SNS_ARN --message "$MESSAGE $TIMESTAMP on s3://$AWS_S3_BUCKET/$AWS_S3_BUCKET_FOLDER/"
    LOG_MSG="Notification sent"
    write_to_log    
}


function check_prebackup_error(){
    #check for prebackup errors
    if [ -f ./prebackup.error ];
    then
        LOG_MSG="Something went wrong in prebackup steps. Please check logfile"
        write_to_log
        error_state=1
    fi
}


function check_postbackup_error(){
    #check for postbackup errors
    if [ -f ./postbackup.error ];
    then
        LOG_MSG="Something went wrong in postbackup steps. Please check logfile"
        write_to_log
        error_state=1
    fi
}

clear

LOG_MSG="**** Start backup $TIMESTAMP ****"
write_to_log

am_i_root

LOG_MSG="Checking prerequisites"
write_to_log

clean_env

check_prerequisites

error_state=0

$HOME_DIR/prebackup.sh

check_prebackup_error

cd $ORACLE_DATA_PUMP_DIR

while read schema_name
do  
    LOG_MSG="-----------------------------------------------------------------------------------"
    write_to_log
    
    LOG_MSG="Processing ${schema_name} "
    write_to_log
    
    LOG_MSG="Datapumping $schema_name... "
    write_to_log
    #Variabile che gestisce eventuali errori solo all'interno dell'iterazione.
    #Viene usata per eseguire o meno lo step successivo
    iteration_error=0
    su - $ORACLE_SO_USER -c "expdp $ORACLE_DB_SYSTEM_USER/$ORACLE_DB_SYSTEM_PASSWORD dumpfile=${schema_name}_${TIMESTAMP}.dump schemas=$schema_name directory=$ORACLE_BACKUP_DIR logfile=${schema_name}_${TIMESTAMP}.log"
    exit_status=$?
    if [ $exit_status -eq 0 ];
    then
        echo "done"
        LOG_MSG="Datapump $schema_name done... "
        write_to_log
    else
        #exit or continue? continue mi sa che è meglio 
        echo "ERROR"
        LOG_MSG="Something went wrong in $schema_name datapump. Jump to next schemas"
        write_to_log
        error_state=1
        iteration_error=1
    fi      
    if [ $iteration_error -eq 0 ];
    then
        LOG_MSG="Tarring ${schema_name}_${TIMESTAMP}.dump... "
        write_to_log
        tar -zcf ${schema_name}_${TIMESTAMP}.tar.gz ${schema_name}_${TIMESTAMP}.dump
        exit_status=$?
        if [ $exit_status -eq 0 ];
        then
            echo "done"
            LOG_MSG="Tar ${schema_name}_${TIMESTAMP}.tar.gz done... "
            write_to_log
        else
            #exit or continue? continue mi sa che è meglio 
            echo "ERROR"
            LOG_MSG="Something went wrong with tar ${schema_name}_${TIMESTAMP}.tar.gz. Jump to next schemas"
            write_to_log
            error_state=1
            iteration_error=1
        fi    
    fi

    if [ $iteration_error -eq 0 ];
    then 
        LOG_MSG="Removing ${schema_name}_${TIMESTAMP}.dump... "
        write_to_log
        rm -rf ${schema_name}_${TIMESTAMP}.dump
        exit_status=$?
        if [ $exit_status -eq 0 ];
        then
            echo "done"
            LOG_MSG="Done with ${schema_name}"
            write_to_log
        else
            echo "ERROR"
            LOG_MSG="Cannot delete ${schema_name}_${TIMESTAMP}.dump... You have to clear it manually"
            write_to_log
            error_state=1
            iteration_error=1
        fi
    fi
    LOG_MSG="-----------------------------------------------------------------------------------"
    write_to_log
done < $BACKUP_SCHEMAS_LIST

#backup mode: 
#               single=backup and push on S3 every single tar.gx file
#               compact= backup and push a huge tar.gz file which contains ALL the single tar.gz

case "$BACKUP_MODE" in
   "single") 
        LOG_MSG="SINGLE backup mode selected... "
        write_to_log
        set_aws_env
        for i in *.tar.gz; do
            echo "moving $i on s3://$AWS_S3_BUCKET/$AWS_S3_BUCKET_FOLDER/";
            LOG_MSG="moving $i on s3://$AWS_S3_BUCKET/$AWS_S3_BUCKET_FOLDER/ ..."
            write_to_log        
            aws s3 cp $i s3://$AWS_S3_BUCKET/$AWS_S3_BUCKET_FOLDER/
            exit_status=$?
            if [ $exit_status -eq 0 ];
            then
                echo "done"
                LOG_MSG="Done"
                write_to_log
            else
                echo "ERROR"
                LOG_MSG="Error in uploading on S3 $i"
                write_to_log
                error_state=1
            fi                 
        done
      ;;
   "compact")
        LOG_MSG="COMPACT backup mode selected... "
        write_to_log
        LOG_MSG="Tarring ... "
        write_to_log
        LOG_MSG="One Tar to rule them all, One Tar to find them, One Tar to bring them all and in the darkness bind them"
        write_to_log        
        tar -zcf ALL_SCHEMAS_${TIMESTAMP}.tar.gz *.tar.gz
        exit_status=$?
            if [ $exit_status -eq 0 ];
            then
                echo "done"
                LOG_MSG="Done"
                write_to_log
            else
                echo "ERROR"
                LOG_MSG="Error tarring ALL_SCHEMAS_${TIMESTAMP}.tar.gz"
                write_to_log
                error_state=1
                #gestione alternativa, in caso iìdi errore nell'upload su S3, esce e notifica l'errore
                #MESSAGE="Somethings went wrong while tarring ALL_SCHEMAS_${TIMESTAMP}.tar.gz . Backup failed"
                #sns_notify
                #exit
            fi                 
        echo "moving ALL_SCHEMAS_${TIMESTAMP}.tar.gz on s3://$AWS_S3_BUCKET/$AWS_S3_BUCKET_FOLDER/";
        LOG_MSG="Moving ALL_SCHEMAS_${TIMESTAMP}.tar.gz on s3://$AWS_S3_BUCKET/$AWS_S3_BUCKET_FOLDER/ ... "
        write_to_log
        set_aws_env
        aws s3 cp ALL_SCHEMAS_${TIMESTAMP}.tar.gz s3://$AWS_S3_BUCKET/$AWS_S3_BUCKET_FOLDER/
        exit_status=$?
        if [ $exit_status -eq 0 ];
        then
            echo "done"
            LOG_MSG="Done"
            write_to_log
        else
            echo "ERROR"
            LOG_MSG="Error in uploading on S3 ALL_SCHEMAS_${TIMESTAMP}.tar.gz"
            write_to_log
            error_state=1
        fi               
      ;;
   *)
      echo "what?!?!?!"
      ;;
esac

clean

$HOME_DIR/postbackup.sh

check_postbackup_error

echo $CURRENT_DIR
cd $CURRENT_DIR

if [ $error_state -eq 0 ];
then
    LOG_MSG="**** Backup seems to be ok. See you next time. Bye  ****"
    MESSAGE=$SNS_MESSAGE
    sns_notify
    write_to_log
else
    LOG_MSG="**** Backup finished whit some errors. Please check this log. Bye ****"
    MESSAGE="BACKUP WITH ERRORS!! Check log for more info $SNS_MESSAGE"
    sns_notify
    write_to_log
fi

#sns_notify

#if [ $error_state -eq 0 ];
#then
#    LOG_MSG="**** Backup seems to be ok. See you next time. Bye  ****"
#else
#    LOG_MSG="**** Backup finished whit some errors. Please check this log. Bye ****"
#fi
