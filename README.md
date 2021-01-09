# raspberry-backup-restore
A simple bash script to backup or restore SSD card of a Raspberry Pi

## Usage
### Backup SSD card
```
rpi_to_img_backup.sh backup <DISK_PATH> -t <BACKUP_FOLDER_PATH>
```

For my Raspberry Pi the full command is :
```
rpi_to_img_backup.sh backup /dev/mmcblk0 -t /mnt/backups
```

`/dev/mmcblk0` is the Linux device for my SSD card, it coould be /dev/sda, or whatever. To know your disk name run `fdisk -l`.
`/mnt/backups` is for my case a NFS mount point to my NAS, you must choose here an external disk, USB or network mount.

### Restore SSD card
```
rpi_to_img_backup.sh restore <GUNZIPED_IMAGE_FILE_PATH> -t <DISK_PATH>
```

Full command example :
```
rpi_to_img_backup.sh restore /mnt/backups/20201113_rpi_piserver.img.gz -t /dev/disk4
```

From another computer, put your SSD card from USB card reader, then run the above command. The computer must be a Linux system or MacOS, Windows is not supported. Be careful when choosing the target DISK_PATH, you can brick your computer if choose a bad disk.
On Linux use `fdisk -l` to found your USB card reader, on MacOS use `diskutil list`.

**CAUTION : I currently not tested the restore function, but this should work without any problem.**

## Automatise the backup
To run the script periodically you can use a `cron` task on your Raspberry. For instance if you want to backup your Raspberry Pi one time per week on Sunday at 4:00 you can use this rule :

`0 4 * * SUN /home/pi/rpi_to_img_backup/rpi_to_img_backup.sh backup /dev/mmcblk0 -t /mnt/backups`

**Please, do not forget to adapt your script path, disk and backup path!**

Here is a very helpfull cron generator : https://crontab.guru/
