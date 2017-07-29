#!/bin/sh

#exec > /backup/log/backup.log

DIRETORIOS="dados usuarios"

DATA=`date "+%Y-%m-%d %H:%M:%S"`
HOST=`uname -n`
STATUS_BKP="/var/www/html/statusbackup_dia.txt"
DIA_SEMANA=`date | cut -d" " -f 1`

#Label do HD de backup, pode ser identificado com o comando bklid
EXT_DEVICE_LABEL="LABEL" #somente alterar aqui
EXT_DEVICE="/dev/disk/by-label/$EXT_DEVICE_LABEL"
EXT_MOUNT="/mnt/hdext"

backup_dia() {

    echo "INFO: ---->  Iniciando Backup de arquivos $HOST em $DATA" > $STATUS_BKP
    DIRETORIO_DIA=`ls /mnt/hdext/backup_dia/ | grep "$DIA_SEMANA"`

    if [ ! -e "$DIRETORIO_DIA" ]
    then
       echo "INFO: Diretorio nao existe, vou criar um diretorio $DIA_SEMANA"
       mkdir /mnt/hdext/backup_dia/$DIA_SEMANA
    else
       echo "INFO: Diretorio ja existe, vou continuar"
    fi

    echo "Removendo backup antigo de $DIA_SEMANA"
    rm -rf /mnt/hdext/backup_dia/$DIA_SEMANA/* &&

    for i in $DIRETORIOS; do
         echo "Copiando /"$i" para /mnt/hdext/backup_dia/$DIA_SEMANA/$i.tar.gz"
         tar -cpjvf /mnt/hdext/backup_dia/$DIA_SEMANA/$i.tar.bz2 /mnt/tank/$i 2>> $STATUS_BKP
    done
    echo "Backup do $DIA_SEMANA $DATA feito com sucesso" >> $STATUS_BKP
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

backup_dia

echo "INFO: Vou desmontar o ponto de montagem $EXT_MOUNT"
echo "INFO: Vou desmontar o ponto de montagem $EXT_MOUNT" >> $STATUS_BKP
umount "$EXT_MOUNT"
