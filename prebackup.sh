#!/bin/bash
##################################################################################################
# DO NOT EDIT
. /opt/faxkup/faxkup.config
##################################################################################################
# DO NOT EDIT
# log function
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
#
#
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
##################################################################################################
#DO NOT EDIT
LOG_MSG="==## Prebackup script ##=="
write_to_log
LOG_MSG="== start "
write_to_log
##################################################################################################
#HERE YOU CAN WRITE YOUR BASH CODE
#
# LOG:
# remember to log script events, to log you just put your log message into "LOG_MSG" variable
# and use "write_to_log" function.
#
# ERROR:
# you can tell to the backup system that something went wrong simply creating a file called
# "prebackup.error" into the faxkup home directory. 
# The backup system will check for this file and if it is present in the faxkup home directory
# the "error_state" will be set to 1, so the sns notification tell to the sysadmin that
# an error occours
#
# VARIABLES
prebakcup_error=0
repository_path=/data
tar_file_output="data.tar.gz"
tar_file_output_path="/opt/tmp"

# DO STUFFS, SEE PEOPLE
LOG_MSG="== creating tmp dir $tar_file_output_path "
write_to_log
# create a temp directory
mkdir -p $tar_file_output_path
exit_status=$?
    if [ $exit_status -eq 0 ];
    then
        LOG_MSG="== done "
        write_to_log
    else
        echo "ERROR"
        LOG_MSG="== Something went wrong creating $tar_file_output_path!"
        write_to_log
        echo $LOG_MSG > ./prebackup.error
        LOG_MSG="== Cannot continue with prebackup script."
        write_to_log
        error_state=1
        prebakcup_error=1
    fi
if [ $prebakcup_error -eq 0 ];
then
    LOG_MSG="== tarring $repository_path folder into $tar_file_output_path/$tar_file_output file  "
    write_to_log
    #tar gz the target folder into the temp directory previously created
    tar -zpcvf $tar_file_output_path/$tar_file_output $repository_path > /dev/null
    exit_status=$?
        if [ $exit_status -eq 0 ];
        then
            LOG_MSG="== done "
            write_to_log
        else
            echo "ERROR"
            LOG_MSG="== Something went wrong tarring!"
            write_to_log
            echo $LOG_MSG > ./prebackup.error
            LOG_MSG="== Cannot continue with prebackup script."
            write_to_log
            error_state=1
            prebakcup_error=1
            
    fi
fi

if [ $prebakcup_error -eq 0 ];
then
    LOG_MSG="== moving $tar_file_output_path/$tar_file_output to $ORACLE_DATA_PUMP_DIR "
    write_to_log
    #moving tarfile into oracle data pump dir so, the backup will keep it with the oracle datapump
    mv $tar_file_output_path/$tar_file_output $ORACLE_DATA_PUMP_DIR
    exit_status=$?
        if [ $exit_status -eq 0 ];
        then
            LOG_MSG="== done "
            write_to_log
        else
            echo "ERROR"
            LOG_MSG="== Something went wrong moving tar!"
            write_to_log
            echo $LOG_MSG > ./prebackup.error            
            LOG_MSG="== Cannot continue with prebackup script."
            write_to_log
            error_state=1
            prebakcup_error=1    
    fi
fi
LOG_MSG="== end "
write_to_log
LOG_MSG="==## Prebackup script ##=="
write_to_log
