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
LOG_MSG="==## Postbackup script ##=="
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
# "postbackup.error" into the faxkup home directory. 
# The backup system will check for this file and if it is present in the faxkup home directory
# the "error_state" will be set to 1, so the sns notification tell to the sysadmin that
# an error occours
#
# VARIABLES
prebakcup_error=0

# DO STUFFS, SEE PEOPLE
LOG_MSG="== nothing to do... "
write_to_log

LOG_MSG="== end "
write_to_log
LOG_MSG="==## Postbackup script ##=="
write_to_log
