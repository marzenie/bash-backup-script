#!/bin/bash
limitsizelocal=85 # Limit miejsca na dysku ( w %), po przekroczeniu którego kopia nie utworzy się aby nie nadpisać plików 
logFile='./logfile.txt' # Plik z Logami dotyczącymi Backupów
EXCLUDE_LIST="/boot"
pathbackup="/backup" # Katalog docelowy gdzie mają być zapisywane kopie zapasowe
pathmysql="/mysql" # Katalog docelowy gdzie mają być zapisywane kopie bazy danych
savebackups="/etc /home /root /var /usr /bin" # Katalogi z których mają być robione kopie | oddzielone spacją 
# Pamiętaj aby katalog gdzie utworzony będzie backup, nie był wpisany do katalogów z których ma być tworzony backup
###############################################


DATA=`date +"%d-%m-%Y,%I:%M"` # data

Start() {
while read output;
do
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  if [ $usep -ge $limitsizelocal ] ; then
		echo "[$DATA] Za mało miejsca na dysku aby utworzyć kopie zapasową. miejsce na dysku $usep%, limit $limitsizelocal%." >> "${logFile}"; 
			exit 0
    else
		tar --warning=no-file-changed --absolute-names -cpzf $pathbackup/$DATA.tar.gz $savebackups
			mysqldump --defaults-file=/etc/mysql/debian.cnf --routines --flush-privileges --all-databases >$pathmysql/$DATA.sql
				echo "[$DATA] Kopia została stworzona" >> "${logFile}"; 
					exit 0
	fi

done
}

Start_APK() {
echo "[$DATA] Uruchomiono Skrypt" >> "${logFile}"; 
find $pathbackup -mtime +7 -exec rm -R {} \; && find $pathmysql -mtime +7 -exec rm -R {} \;
if [ "$EXCLUDE_LIST" != "" ] ; then
  df -hP |  grep -vE "^[^/]|tmpfs|cdrom|${EXCLUDE_LIST}" | awk '{print $5 " " $6}' | Start
fi
}

case "$1" in
    start|Start|START) Start_APK ;;
		* ) echo "Poprawne uzycie: $0 Start" >&2
	exit 1
    ;;
esac

# By Marzycielx - Marszałek Szymon 2020.
# Pozdrawiam każdą osobę w każdych okolicznościach która to czyta :) 
