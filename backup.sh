#!/bin/bash
limitsizelocal=85 # Disk space limit (in %), beyond which a copy will not be created to avoid overwriting the files
logFile='./logfile.txt' # File with Backup Logs
EXCLUDE_LIST="/boot"
pathbackup="/backup" # Target directory where backups are to be saved
pathmysql="/mysql" # Target directory where database copies are to be saved
savebackups="/etc /home /root /var /usr /bin" # Directories from which copies should be made | separated by a space
# Remember that the directory where the backup will be created should not be included in the directories from which the backup is to be created
###############################################


DATA=`date +"%d-%m-%Y,%I:%M"` # data

Start() {
while read output;
do
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  if [ $usep -ge $limitsizelocal ] ; then
		echo "[$DATA] There is not enough disk space to create a backup. disk space $usep%, limit $limitsizelocal%." >> "${logFile}"; 
			exit 1
    else
		tar --warning=no-file-changed --absolute-names -cpzf $pathbackup/$DATA.tar.gz $savebackups
			mysqldump --defaults-file=/etc/mysql/debian.cnf --routines --flush-privileges --all-databases >$pathmysql/$DATA.sql
				echo "[$DATA] The copy has been created" >> "${logFile}"; 
					exit 0
	fi

done
}

Start_APK() {
echo "[$DATA] Script started" >> "${logFile}"; 
find $pathbackup -mtime +7 -exec rm -R {} \; && find $pathmysql -mtime +7 -exec rm -R {} \;
if [ "$EXCLUDE_LIST" != "" ] ; then
  df -hP |  grep -vE "^[^/]|tmpfs|cdrom|${EXCLUDE_LIST}" | awk '{print $5 " " $6}' | Start
fi
}

case "$1" in
    start|Start|START) Start_APK ;;
		* ) echo "Correct use: $0 Start" >&2
	exit 1
    ;;
esac

# By Marzycielx - Marszałek Szymon 2020.
# Greetings to every person in all circumstances who reads this :)
