#!/bin/sh

exec 1>/var/log/backup.log 2>/var/log/backup.log

DATA=`date "+%Y-%m-%d %H:%M:%S"`
HOST=`uname -n`
STATUS_BKP="/var/www/html/statusbackup.txt"


#Label do HD de backup, pode ser identificado com o comando bklid
EXT_DEVICE_LABEL="NOME" #somente alterar aqui
EXT_DEVICE="/dev/disk/by-label/$EXT_DEVICE_LABEL"

#Ponto de montagem do HD de backup
EXT_MOUNT="/mnt/hdext"

#Path do diretorio do backup. Em alguns casos podem ser /home ou em /mnt/tank. Depende onde foi armazenados os diretorios a serem backpeados
PATH_DIR_BKP="/mnt/tank"

#Diretórios a serem backupeados
DIR_BKP="dados usuarios"


echo "============================ Status do ultimo backup dos dados do [$HOST] em [$DATA] ======================" > $STATUS_BKP
chmod 777 $STATUS_BKP

# echo  >> $STATUS_BKP
# echo "--->Opcoes usadas no rsync." >> $STATUS_BKP
# echo "-C, --cvs-exclude - ignora arquivos CVS." >> $STATUS_BKP
# echo "-r, --recursive - recursivo." >> $STATUS_BKP
# echo "-a, --archive - modo arquivo; igual -rlptgoD (no -H,-A,-X)." >> $STATUS_BKP
# echo "-z, --compress - comprime durante transferência." >> $STATUS_BKP
# echo "-p, --perms - preserva as permissões." >> $STATUS_BKP
# echo "-t, --times - preserva a data de modificação" >> $STATUS_BKP
# echo "-v, --verbose - modo verboso." >> $STATUS_BKP
# echo "--delete - apaga durante o processo." >> $STATUS_BKP
# echo  >> $STATUS_BKP

sincroniza() {

    echo
    echo "=========================================== [$DATA] Iniciando backup ====================================================" >> $STATUS_BKP
    echo

    for dir in $DIR_BKP; do
       status="Falha"
       rsync  -Cravzpt --delete $PATH_DIR_BKP/$dir "$EXT_MOUNT"/backup && status="Sucesso"
       echo "$PATH_DIR_BKP/$dir -----> [$status]" >> $STATUS_BKP
    done

 
}

#sincronisa_nuvem() {
#    dir_nuvem="Compartilhado"
#    for j in $dir_nuvem; do
#       rclone sync -v /mnt/tank/dados/$j Amazon:dados && status1="Sucesso"
#        echo "/mnt/tank/$j - [$status1]" >> $STATUS_BKP
#    done
#}


verifica_hd() {

	total=`df | grep sdb1 | awk '{print $2}' 2>> /dev/null`
	livre=`df | grep sdb1 | awk '{print $3}' 2>> /dev/null`
	ocupado=`df | grep sdb1 | awk '{print $4}' 2>> /dev/null`
	percent_li=$(($ocupado * 100 / $total))
	percent_oc=$((100 - $percent_li))
#	echo "$percent_oc" >> $STATUS_BKP
	echo >> $STATUS_BKP
	echo >> $STATUS_BKP
	echo "INFO: Uso de disk /dev/sdb1 Ocupado: $percent_oc %" >> $STATUS_BKP
}



if [ ! -e "$EXT_DEVICE" ]
then
    echo "ERRO: O dispositivo externo $EXT_DEVICE nao esta conectado ou o label da particao nao confere." >> $STATUS_BKP
    exit 1
fi

EXISTS=$(mount -l | grep "$EXT_MOUNT" | grep "$EXT_DEVICE_LABEL")

if [ "$EXISTS" = "" ]
then
    echo "INFO: Dispositivo externo $EXT_DEVICE nao esta montado em $EXT_MOUNT" >> $STATUS_BKP
    echo "INFO: Vou montar o dispositivo $EXT_DEVICE em $EXT_MOUNT" >> $STATUS_BKP
    echo  >> $STATUS_BKP
    mount "$EXT_DEVICE" "$EXT_MOUNT" || exit 1
fi



sincroniza
#sincronisa_nuvem
verifica_hd


echo "INFO: Vou desmontar o ponto de montagem $EXT_MOUNT"
echo "INFO: Vou desmontar o ponto de montagem $EXT_MOUNT" >> $STATUS_BKP
umount "$EXT_MOUNT"

echo "=========================================== [$DATA] Backup concluido ====================================================" >> $STATUS_BKP



