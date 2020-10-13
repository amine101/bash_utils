#!/bin/bash
# last edited 27/05/2020
shopt -s extglob  

#---- PATHS -----
BACKUP_RESTORE_LOG_FILE="/home/amin/logs/backup_restore.log"

EMBY_RECOVERY_PATH="/media/amin/E/Software/RECOVERY/Ubuntu/Emby"
EMBY_PATH="/var/lib/emby"

SAMBA_PATH="/etc/samba/smb.conf"
SAMBA_RECOVERY_PATH="/media/amin/E/Software/RECOVERY/Ubuntu/Others"

MANAGEMENT_PATH="/home/amin/management"
MANAGEMENT_RECOVERY_PATH="/media/amin/E/Software/RECOVERY/Ubuntu/management"


PROJECTS_PATH="/media/amin/E/projects"
PROJECTS_RECOVERY_PATH="/media/amin/E/Software/RECOVERY/Ubuntu/projects"

SAVED_PATH="/home/amin/saved"
SAVED_RECOVERY_PATH="/media/amin/E/Software/RECOVERY/Ubuntu/saved"

APACHE_PATH="/home/amin/saved/apache/custom"
APACHE_RECOVERY_PATH="/media/amin/E/Software/RECOVERY/Ubuntu/Apache"




KDECONNECT_SECURITY="False"
KDECONNECT_TRUSTED_DEVICES="/home/amin/.config/kdeconnect/trusted_devices"
KDECONNECT_MANUAL_RECOVERY_PATH="/media/amin/E/Software/RECOVERY/Ubuntu/KDEconnect/kdeconnect"           #file ( extension = txt or enc ) 
KDECONNECT_CONFIG_RECOVERY_PATH="/media/amin/E/Software/RECOVERY/Ubuntu/KDEconnect/config"               #file ( extension = enc if encrypted  or nothing  ) 
DEVICE_ID=$(awk 'NR==1{ gsub ( /[][]/, "" ) ;  print }'  $KDECONNECT_TRUSTED_DEVICES  ) 
KDECONNECT_CONFIG_PATH="/home/amin/.config/kdeconnect/$DEVICE_ID/kdeconnect_runcommand/config"           #file 

#DEVICE_ID=


#---- /PATHS -----

#---- DEFAULT -----
LOG_LEVEL="DEBUG"
EMBY="None"
APACHE="None"
MANAGEMENT="None"
SAMBA="None"
PROJECTS="None"
SAVED="None"
MONGODB="None"
#---- /DEFAULT -----



#------------------- LOGS ----------------
# MORE INFO :    https://serverfault.com/questions/103501/how-can-i-fully-log-all-bash-scripts-actions
# MORE INFO :    https://www.cubicrace.com/2016/03/efficient-logging-mechnism-in-shell.html
# MORE INFO :    https://unix.stackexchange.com/questions/145651/using-exec-and-tee-to-redirect-logs-to-stdout-and-a-log-file-in-the-same-time
# TODO      :    Make LOG_LEVEL apply to all output (not just the predefined logging functions) based on the returnd value of each instruction.
source /home/amin/management/logger.sh $@
#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1>  >( sudo tee -a "/home/amin/logs/backup_restore.log" ) 2>&1
SCRIPTENTRY 
#------------------- /LOGS ----------------






#--------------------------------------- FUNCTIONS --------------------------------------------------

parsing()
#----------------------------------------------------------------------------
# This function parses al string that contains substrings separated by the "," character.
# If a substring is valid, then it sets the correspendant default backup/restore flag with "backup" or "restore" ( $1 ) 
#----------------------------------------------------------------------------
# ($1) "backup" or "restore"  (Important to set the backup/restore flags)
# ($2)  list of elememts that should be separated by ,
#----------------------------------------------------------------------------
{       Input=$2
        result=$2
        field="1"
        while [ "$result" != "" ]
        do
            result=$(echo $Input |   awk -F","  -v field="$field" '{ print $field }' )
            if grep -q -i "EMBY" <<<"$result"; then  EMBY=$1 &&  INFO "Valid field n°$field :$result" ; fi
            if grep -q -i "SAMBA" <<<"$result"; then  SAMBA=$1 &&  INFO "Valid field n°$field :$result"; fi
            if grep -q -i "MANAGEMENT" <<<"$result"; then  MANAGEMENT=$1 &&  INFO "Valid field n°$field :$result" ; fi
            if grep -q -i "KDECONNECT" <<<"$result"; then  KDECONNECT=$1 &&  INFO "Valid field n°$field :$result" ; fi
            if grep -q -i "PROJECTS" <<<"$result"; then  PROJECTS=$1 &&  INFO "Valid field n°$field :$result" ; fi
            if grep -q -i "SAVED" <<<"$result"; then  SAVED=$1 &&  INFO "Valid field n°$field :$result" ; fi
            if grep -q -i "MONGODB" <<<"$result"; then  MONGODB=$1 &&  INFO "Valid field n°$field :$result" ; fi
            # To add more 
            
            
            (( field = field + 1 ))
        done
}

#--------------------------------------- /FUNCTIONS --------------------------------------------------





#__________________________________ READING ARGUMENTS  ________________________________________
for arg in "$@"
do
case $arg in
        --restore=*)
        #([^,;]*)(,[^,;]+)*
        parsing "restore" ${arg#*=}
        shift
        ;;

        --backup=* )
        #([^,;]*)(,[^,;]+)*
        parsing "backup" ${arg#*=}
        shift
        ;;
        
        --cron )        
        shift
        ;;
        --log@(_level|)=@(debug|info|warning|error|DEBUG|INFO|WARNING|ERROR))
        LOG_LEVEL=${arg#*=}
        LOG_LEVEL=${LOG_LEVEL^^}
        source /home/amin/management/logger.sh $@
        shift
        ;;
        --debug|--info|--warning|--error)
        LOG_LEVEL=${arg:2}
        LOG_LEVEL=${LOG_LEVEL^^}
        source /home/amin/management/logger.sh $@
        shift
        ;;
        --log@(_level|)=*)
        WARNING "NOT SUPPORTED LOG_LEVEL was provided. Keeping the default level : $LOG_LEVEL"
        shift
        ;;
        
        
        *)    # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        ERROR "Not valid entry $1"
        shift 
esac;
done
#__________________________________ /READING ARGUMENTS  ________________________________________





#------------------------------------- MANAGEMENT -------------------------------------
if [[ "$MANAGEMENT" == "restore"  ]]
then
DEBUG " rsync -aAXpv --delete  $MANAGEMENT_RECOVERY_PATH/  $MANAGEMENT_PATH/ "  
sudo rsync -aAXpv --delete  $MANAGEMENT_RECOVERY_PATH/  $MANAGEMENT_PATH/
elif [[ "$MANAGEMENT" == "backup" ]]
then
DEBUG "sudo rsync -aAXpv --delete $MANAGEMENT_PATH/ $MANAGEMENT_RECOVERY_PATH/" 
sudo rsync -aAXpv --delete "$MANAGEMENT_PATH/" "$MANAGEMENT_RECOVERY_PATH/"
fi
#-------------------------------------- /MANAGEMENT ------------------------------------


#------------------------------------- SAVED -------------------------------------
if [[ "$SAVED" == "restore"  ]]
then
DEBUG " rsync -aAXpv --delete  $SAVED_RECOVERY_PATH/  $SAVED_PATH/ "  
sudo rsync -aAXpv --delete  "$SAVED_RECOVERY_PATH/"  "$SAVED_PATH/"
elif [[ "$SAVED" == "backup" ]]
then
DEBUG "sudo rsync -aAXpv --delete $SAVED_PATH/ $SAVED_RECOVERY_PATH/" 
sudo rsync -aAXpv --delete "$SAVED_PATH/" "$SAVED_RECOVERY_PATH/"
fi
#-------------------------------------- /SAVED ------------------------------------



#------------------------------------- PROJECTS -------------------------------------
if [[ "$PROJECTS" == "restore"  ]]
then
DEBUG " rsync -aAXpv --delete  $PROJECTS_RECOVERY_PATH/  $PROJECTS_PATH/ "  
sudo rsync -aAXpv --delete  "$PROJECTS_RECOVERY_PATH/"  "$PROJECTS_PATH/"
elif [[ "$PROJECTS" == "backup" ]]
then
DEBUG "sudo rsync -aAXpv --delete $PROJECTS_PATH/ $PROJECTS_RECOVERY_PATH/" 
sudo rsync -aAXpv --delete "$PROJECTS_PATH/" "$PROJECTS_RECOVERY_PATH/"
fi
#-------------------------------------- /PROJECTS ------------------------------------



#----------------------------------- SAMBA ---------------------------------------
if [[ "$SAMBA" == "restore"  ]]
then
DEBUG "sudo rsync -aAXpv --delete  "$SAMBA_RECOVERY_PATH/"$(basename $SAMBA_PATH)  $SAMBA_PA"  
sudo rsync -aAXpv --delete  "$SAMBA_RECOVERY_PATH/"$(basename $SAMBA_PATH)  "$SAMBA_PATH"
elif [[ "$SAMBA" == "backup" ]]
then
DEBUG "sudo rsync -aAXpv --delete $SAMBA_PATH $SAMBA_RECOVERY_PATH/"
sudo rsync -aAXpv --delete "$SAMBA_PATH" "$SAMBA_RECOVERY_PATH/"
  
fi
#---------------------------------- /SAMBA ----------------------------------------


#_______________________________ EMBY ___________________________________________

if [[ "$EMBY" == "restore"  ]]
then
DEBUG "sudo rsync -aAXpv --delete "${EMBY_RECOVERY_PATH}/"$(basename $EMBY_PATH)/  $EMBY_PATH/" 
sudo rsync -aAXpv --delete "${EMBY_RECOVERY_PATH}/"$(basename $EMBY_PATH)/  $EMBY_PATH/

elif [[ "$EMBY" == "backup" ]]
then
DEBUG "sudo rsync -aAXpv --delete  $EMBY_PATH $EMBY_RECOVERY_PATH  " 
rsync -aAXpv --delete  "$EMBY_PATH" "$EMBY_RECOVERY_PATH"  
#--exclude= \
fi
#_________________________________ /EMBY _________________________________________


#_______________________________ KDECONNECT ___________________________________________

if [[ "$KDECONNECT" == "restore"  ]]
then
    if [[ "$KDECONNECT_SECURITY" == "True"  ]]
    then
        DEBUG "openssl enc -aes-256-cbc -d -iter :P -in  $KDECONNECT_CONFIG_RECOVERY_PATH.enc -out  $KDECONNECT_CONFIG_PATH" 
        openssl enc -aes-256-cbc -d -iter 1000 -in  "$KDECONNECT_CONFIG_RECOVERY_PATH.enc" -out  "$KDECONNECT_CONFIG_PATH"
        if [[  -f $KDECONNECT_MANUAL_RECOVERY_PATH.enc ]]; then 
            DEBUG "openssl enc -aes-256-cbc -d -iter :P -in  $KDECONNECT_MANUAL_RECOVERY_PATH.enc -out  $KDECONNECT_MANUAL_RECOVERY_PATH.txt" 
            openssl enc -aes-256-cbc -d -iter 1000 -in  "$KDECONNECT_MANUAL_RECOVERY_PATH.enc" -out  "$KDECONNECT_MANUAL_RECOVERY_PATH.txt"
            sudo rm -rf "$KDECONNECT_MANUAL_RECOVERY_PATH.enc"
        else
            WARNING "$KDECONNECT_MANUAL_RECOVERY_PATH.enc does not exist because  it's already decrypted"
        fi
    else
        DEBUG "sudo rsync -aAXpv --delete  $KDECONNECT_CONFIG_RECOVERY_PATH  $KDECONNECT_CONFIG_PATH"  
        sudo rsync -aAXpv --delete  "$KDECONNECT_CONFIG_RECOVERY_PATH"  "$KDECONNECT_CONFIG_PATH"
    fi

elif [[ "$KDECONNECT" == "backup" ]]
then
    if [[ "$KDECONNECT_SECURITY" == "True"  ]]
        then
        DEBUG "openssl enc -aes-256-cbc  -iter :P -in $KDECONNECT_CONFIG_PATH -out   $KDECONNECT_CONFIG_RECOVERY_PATH.enc"
        openssl enc -aes-256-cbc  -iter 1000 -in "$KDECONNECT_CONFIG_PATH" -out   "$KDECONNECT_CONFIG_RECOVERY_PATH.enc"
        if [[ !  -f $KDECONNECT_MANUAL_RECOVERY_PATH.enc ]]; then
            DEBUG "openssl enc -aes-256-cbc -iter :P -in  $KDECONNECT_MANUAL_RECOVERY_PATH.txt -out  $KDECONNECT_MANUAL_RECOVERY_PATH.enc"
            if [[ !  -f "$KDECONNECT_MANUAL_RECOVERY_PATH.txt" ]]; then 
                WARNING "$KDECONNECT_MANUAL_RECOVERY_PATH.txt does not exist because  it's already encrypted."
            else
                openssl enc -aes-256-cbc -iter 1000 -in  "$KDECONNECT_MANUAL_RECOVERY_PATH.txt" -out  "$KDECONNECT_MANUAL_RECOVERY_PATH.enc"  && \
                sudo rm -rf  "$KDECONNECT_MANUAL_RECOVERY_PATH.txt"
            fi
        fi

    else 
        DEBUG "sudo rsync -aAXpv --delete $KDECONNECT_CONFIG_PATH $KDECONNECT_CONFIG_RECOVERY_PATH/"
        sudo rsync -aAXpv --delete "$KDECONNECT_CONFIG_PATH" "$KDECONNECT_CONFIG_RECOVERY_PATH/"
    fi
fi
#_________________________________ /KDECONNECT _________________________________________



#_______________________________ EMBY ___________________________________________

if [[ "$EMBY" == "restore"  ]]
then
DEBUG "sudo rsync -aAXpv --delete "${EMBY_RECOVERY_PATH}/"$(basename $EMBY_PATH)/  $EMBY_PATH/" 
sudo rsync -aAXpv --delete "${EMBY_RECOVERY_PATH}/"$(basename $EMBY_PATH)/  $EMBY_PATH/

elif [[ "$EMBY" == "backup" ]]
then
DEBUG "sudo rsync -aAXpv --delete  $EMBY_PATH $EMBY_RECOVERY_PATH  " 
rsync -aAXpv --delete  "$EMBY_PATH" "$EMBY_RECOVERY_PATH"  
#--exclude= \
fi
#_________________________________ /EMBY _________________________________________






SCRIPTEXIT
