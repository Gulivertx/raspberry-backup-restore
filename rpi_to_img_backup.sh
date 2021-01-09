#/!bin/bash

### INFO ########################################################
# Simple backup script to backup/restore entire of your RPI SSD card to an img.gz
# By Gulivert aka Cédric Bapst
# https://gulivert.ch
#################################################################

VERSION="0.1"
PID_FILE="/tmp/rpi_to_img_backup.pid"
LOG_DIRECTORY="/var/rpi_to_img_backup"

# Check current OS
RUNNING_OS="$(uname -s)"
case ${RUNNING_OS} in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${RUNNING_OS}"
esac

DISK=""
TARGET=""
IMAGE=""

Help()
{
    ### Display Help
    echo "Raspberry Pi disk backup / restore"
    echo "Version $VERSION"
    echo "https://gulivert.ch"
    echo "____________________________________________________________________________"
    echo ""
    echo "Usage:"
    echo "  rpi_to_img_backup.sh backup <DISK_PATH> -t <BACKUP_FOLDER_PATH>"
    echo "  rpi_to_img_backup.sh restore <GUNZIPED_IMAGE_FILE_PATH> -t <DISK_PATH>"
    echo ""
}

Backup()
{
    ### Verify if a script already running
    if [[ -f ${PID_FILE} ]]; then
        echo "Error: an other process of the script is still running" >&2
        exit 1
    fi

    if [[ MACHINE -ne "Linux" ]]; then
        echo "Error: Backup can only run on Linux OS" >&2
        exit 1
    fi

    ### Create a pid file
    echo $$ > ${PID_FILE}

    echo "Start backup your disk : $DISK"
    echo "Please wait..."

    CURRENT_DATE=`date +"%Y%m%d"`
    HOSTNAME="$(hostname)"

    # dd bs=4M if=/dev/mmcblk0 | gzip > /mnt/backups/20201112_rpi_server.img.gz
    dd bs=4M if=${DISK} status=progress | gzip > ${TARGET}/${CURRENT_DATE}_rpi_${HOSTNAME}.img.gz

    echo ""
    echo "Disk backuped with success"
    
    rm -f ${PID_FILE}

    exit 0
}

Restore()
{
    ### Verify if a script already running
    if [[ -f ${PID_FILE} ]]; then
        echo "Error: an other process of the script is still running" >&2
        exit 1
    fi

    if [[ MACHINE -ne "Cygwin" ]] || [[ MACHINE -ne "MinGw" ]]; then
        echo "Error: Windows machine is not supported to restore a backup, use a MacOS or Linux" >&2
        exit 1
    fi

    ### Create a pid file
    echo $$ > ${PID_FILE}

    if [[ MACHINE -eq "Linux" ]]; then
        gunzip --stdout ${IMAGE} | sudo dd bs=4M of=${TARGET} status=progress
    elif [[ MACHINE -eq "Mac" ]]; then
        gunzip --stdout ${IMAGE} | sudo dd bs=4m of=${TARGET} status=progress
    else
        echo "Error: Machine $MACHINE is not supported to restore a backup, use MacOS or Linux" >&2
        rm -f ${PID_FILE}
        exit 1
    fi

    echo ""
    echo "SSD card restored with success"

    rm -f ${PID_FILE}

    exit 0
}

# Parse options to the 'rpi_to_img_backup.sh' command
while getopts ":h" opt; do
   case ${opt} in
      h) # display Help
         Help
         exit 0
         ;;
      \?)
         echo "Invalid Option: -$OPTARG" 1>&2
         exit 1
         ;;
   esac
done
shift $((OPTIND -1))

SUBCOMMAND=$1; shift  # Remove 'rpi_to_img_backup.sh' from the argument list
if [[ -z ${SUBCOMMAND} ]]; then
    Help
    exit 1
fi

case "$SUBCOMMAND" in
  # Parse options to the backup sub command
  backup)
    DISK=$1; shift  # Remove 'backup' from the argument list

    # Process backup options
    while getopts ":t:" opt; do
      case ${opt} in
        t )
          TARGET=$OPTARG
          Backup
          ;;
        \? )
          echo "Invalid Option: -$OPTARG" 1>&2
          exit 1
          ;;
        : )
          echo "Invalid Option: -$OPTARG requires an argument" 1>&2
          exit 1
          ;;
      esac
    done
    shift $((OPTIND -1))
    ;;
  restore)
    IMAGE=$1; shift  # Remove 'restore' from the argument list

    # Process backup options
    while getopts ":t:" opt; do
      case ${opt} in
        t )
          TARGET=$OPTARG
          Restore
          ;;
        \? )
          echo "Invalid Option: -$OPTARG" 1>&2
          exit 1
          ;;
        : )
          echo "Invalid Option: -$OPTARG requires an argument" 1>&2
          exit 1
          ;;
      esac
    done
    shift $((OPTIND -1))
    ;;
esac
