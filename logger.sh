#!/bin/sh

DELIMITER="----------------------"
ERROR_LOG_LEVEL_NUMBER=50   #LOG_LEVEL=ERROR
WARNING_LOG_LEVEL_NUMBER=40 #LOG_LEVEL=WARNING
INFO_LOG_LEVEL_NUMBER=30    #LOG_LEVEL=INFO
DEBUG_LOG_LEVEL_NUMBER=20   #LOG_LEVEL=DEGUG
#echo "LOG_LEVEL = $LOG_LEVEL"


#---------------

passed_argument=$@



case "$LOG_LEVEL" in
    ERROR) LOG_LEVEL_NUMBER=$ERROR_LOG_LEVEL_NUMBER  ;;
    WARNING) LOG_LEVEL_NUMBER=$WARNING_LOG_LEVEL_NUMBER  ;;
    INFO) LOG_LEVEL_NUMBER=$INFO_LOG_LEVEL_NUMBER  ;;
    DEBUG) LOG_LEVEL_NUMBER=$DEBUG_LOG_LEVEL_NUMBER ;;
    *)
       LOG_LEVEL="INFO"
       LOG_LEVEL_NUMBER="$INFO_LOG_LEVEL_NUMBER"
       ;;
esac

script_name=`basename "$0"`
_hostname_=$(cat /etc/hostname )

function SCRIPTENTRY(){
 timeAndDate=`date`
 script_name="${script_name%.*}"
 echo -e "$DELIMITER\n[$_hostname_][$script_name] [$FUNCNAME] $passed_argument "
}

function SCRIPTEXIT(){
 script_name=`basename "$0"`
 script_name="${script_name%.*}"
 echo -e "[$timeAndDate][$_hostname_][$script_name] [$FUNCNAME]  \n$DELIMITER"

}

function ENTRY(){
 local cfn="${FUNCNAME[1]}"
 timeAndDate=`date`
 echo -e "[$timeAndDate]   >  [$FUNCNAME]  $cfn "
}

function EXIT(){
 local cfn="${FUNCNAME[1]}"
 timeAndDate=`date`
 echo -e "[$timeAndDate]   <  [$FUNCNAME]  $cfn "

}


function ERROR(){
 local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
    if [ "$LOG_LEVEL_NUMBER" -le "$ERROR_LOG_LEVEL_NUMBER" ]
    then
    echo -e "[$timeAndDate][$_hostname_][$script_name] [ERROR]  $msg"
    fi
}
#---------------

function WARNING(){
 local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
    if [ "$LOG_LEVEL_NUMBER" -le "$WARNING_LOG_LEVEL_NUMBER" ]
    then
    echo "[$timeAndDate][$_hostname_][$script_name] [WARNING]  $msg"
    fi
}


function INFO(){
 local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
    if [ "$LOG_LEVEL_NUMBER" -le "$INFO_LOG_LEVEL_NUMBER" ]
    then
    echo -e "[$timeAndDate][$_hostname_][$script_name] [INFO]  $msg"
    fi
}


function DEBUG(){
 local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
    if [ "$LOG_LEVEL_NUMBER" -le "$DEBUG_LOG_LEVEL_NUMBER" ]
    then
       echo -e "[$timeAndDate][$_hostname_][$script_name] [DEBUG]  $msg"
    fi
}

#---------------
