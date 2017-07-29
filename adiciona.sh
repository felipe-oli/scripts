#!/bin/bash

Principal() {
   clear

   echo "Aplicativo para Adicionar e Remover Usuarios do Samba"
   echo "+---------------------------------------------------------+"
   echo
   echo "Opções:"
   echo "1 - Adicionar Usuario"
   echo "2 - Excluir Usuario"
   echo "3 - Alterar Senha Usuario"
   echo "4 - Listar Usuarios"
   echo "5 - Adicionar Computador"
   echo "6 - Sair"
   echo
   echo -n "Entre com a opção desejada -> "
   read OPCAO
   echo
   case $OPCAO in
      1) Adicionar ;;
      2) Excluir ;;
      3) Alterar ;;
      4) Listar ;;
      5) Computador ;;
      6) exit ;;
      *) "Opção invalida." ; echo ; Principal ;;
   esac
}

Adicionar() {
   echo -n "Entre com o nome de usuario: "
   read LOGIN
   echo -n "Entre com o grupo deste usuario(caso seja mais de um grupo separe por virgulas): "
   read GRUPO
   echo -n "Entre com o nome completo do usuario: "
   read NOME
   echo -n "Digite a senha do usuario: "
   stty echo
   read SENHA
   stty echo
   echo
   echo "Dados carregados: $LOGIN $GRUPO $SENHA "
   echo
   /usr/sbin/useradd -m -d /home/$LOGIN -s /bin/false -G $GRUPO $LOGIN
   (echo $SENHA ; echo $SENHA) | smbpasswd -a $LOGIN
#   /usr/bin/gpasswd -a $LOGIN $GRUPO
   echo
   sleep 3
   echo "Adicionado o usuário $LOGIN"
   /usr/bin/groups $LOGIN
   echo "Pressione qualquer tecla para continuar..."
   read MSG
   Principal
}

Excluir () {
   echo -n "Entre com o nome do usuario a excluir: "
   read LOGIN
   echo
   echo "INFO: Removendo usuário "
   echo
   /usr/bin/smbpasswd -x $LOGIN
   echo
   /usr/sbin/userdel $LOGIN
   echo
   /bin/rm -rf /home/$LOGIN
   echo
   echo "Pressione qualquer tecla para continuar..."
   read MSG
   Principal
}

Alterar () {
   echo -n "Entre com o nome de usuário para alterar a senha: "
   read LOGIN
   echo -n "Entre com a senha do usuario para alterar: "
   stty -echo
   read SENHA
   stty echo
   echo
   echo "INFO: Alterando senha"
   (echo $SENHA ; echo $SENHA) | smbpasswd -a $LOGIN
   echo
   echo "Pressione qualquer tecla para continuar..."
   read MSG
   Principal
}

Computador () {
   echo -n "Entre com o nome do computador: "
   read LOGIN
   /usr/sbin/useradd $LOGIN$ ; /usr/bin/passwd -l $LOGIN$ ; smbpasswd -a -m $LOGIN
   echo
   echo "INFO: Adicionando conta de maquina"
   echo
   echo "Pressione qualquer tecla para continuar..."
   read MSG
   Principal
}

Listar () {
   echo "Lista Usuario Samba: "
#   cat /etc/samba/smbpasswd | awk 'BEGIN{ FS=":" } { print "Usuario:" $1 "\t" "Id:" $2 } ' | more
#   read MSG
   echo "Lista Usuario do Sistema: "
#   cat /etc/passwd | awk 'BEGIN{ FS=":" } { print "Usuario:" $1 "\t" "Id:" $3 } ' | more
#   cat /etc/group | more
   echo "Pressione qualquer tecla para continuar..."
   read MSG
   Principal
}

Principal

