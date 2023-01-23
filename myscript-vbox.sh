#!/bin/bash
#ssh-keygen
#cd /home/bitnami/.ssh
#cat id_rsa.pub >> /home/bitnami/.ssh/authorized_keys
#echo " key pair created"
# Description:
# This script sets certain parameters in /etc/ssh/sshd_config.
# It's not production ready and only used for training purposes.
#
# What should it do?
# * Check whether a /etc/ssh/sshd_config file exists
# * Create a backup of this file
# * Edit the file to set certain parameters
# * Reload the sshd configuration
# To enable debugging mode remove '#' from the following line
#set -x
# Variables

#sudo passwd
#su
stop_ssh_file="/etc/ssh/sshd_not_to_be_run"

find_stop_ssh_file(){
  if [ -f ${file} ]
  then
    sudo rm -f ${stop_ssh_file} 
    /usr/bin/echo "File ${stop_ssh_file} is deleted successful"
  else
    /usr/bin/echo "File ${stop_ssh_file} not found."
    exit 1
  fi
}


file="$1"
param[1]="PermitRootLogin"
param[2]="PubkeyAuthentication"
param[3]="AuthorizedKeysFile"
param[4]="PasswordAuthentication"

# Functions
usage(){
  cat << EOF
    usage: $0 ARG1
    ARG1 Name of the sshd_config file to edit.
    In case ARG1 is empty, /etc/ssh/sshd_config will be used as default.

    Description:
    This script sets certain parameters in /etc/ssh/sshd_config.
    It's not production ready and only used for training purposes.

    What should it do?
    * Check whether a /etc/ssh/sshd_config file exists
    * Create a backup of this file
    * Edit the file to set certain parameters
EOF
}

backup_sshd_config(){
  if [ -f ${file} ]
  then
    /usr/bin/cp ${file} ${file}.bak
  else
    /usr/bin/echo "File ${file} not found."
    exit 1
  fi
}

edit_sshd_config(){
  for PARAM in ${param[@]}
  do
    /usr/bin/sed -i '/^'"${PARAM}"'/d' ${file}
    /usr/bin/echo "All lines beginning with '${PARAM}' were deleted from ${file}."
  done
  /usr/bin/echo "${param[1]} yes" >> ${file}
  /usr/bin/echo "'${param[1]} yes' was added to ${file}."
#  /usr/bin/echo "${param[2]}  no" >> ${file}
#  /usr/bin/echo "'${param[2]} yes' was added to ${file}."
#  /usr/bin/echo "${param[3]}  ~/.ssh/authorized_keys" >> ${file}
#  /usr/bin/echo "'${param[3]}  ~/.ssh/authorized_keys' was added to ${file}."
  /usr/bin/echo "${param[4]} yes" >> ${file}
  /usr/bin/echo "'${param[4]} yes' was added to ${file}"
}

reload_sshd(){
  sudo systemctl enable ssh
  sudo systemctl reload sshd
  /usr/bin/echo "Run '/usr/bin/systemctl reload sshd.service'...OK"
}

# main
while getopts .h. OPTION
do
  case $OPTION in
    h)
    usage
    exit;;
    ?)
    usage
    exit;;
  esac
done

if [ -z "${file}" ]
then

file="/etc/ssh/sshd_config"
fi
find_stop_ssh_file
backup_sshd_config
edit_sshd_config
reload_sshd
#find  / -name *.bb -type f -print -exec  rm -f {} \;

#reset  mariadb  root password

/usr/bin/echo "#reset  mariadb  root password"
/usr/bin/echo "#stop mariadb service"
sudo /opt/bitnami/ctlscript.sh stop mariadb
/usr/bin/echo "# change my.cnf bind_address=0.0.0.0"
mycnf_bind="/opt/bitnami/mariadb/conf/my.cnf"
par="bind_address"
/usr/bin/sed -i '/^'"${par}"'/d' ${mysqld_safe}
/usr/bin/echo "All lines beginning with '${par}' were deleted from ${mysqld_safe}."
/usr/bin/echo "${par} = 0.0.0.0" >> ${mysqld_safe}
/usr/bin/echo "'${par} =0.0.0.0' was added to ${mysqld_safe}"
#/usr/bin/echo "# resart mariadb"
#sudo systemctl start mariadb

#open 3306 port for remote access mariadb
sudo iptables -I INPUT -p tcp --dport 3306 -j ACCEPT
iptables-save
apt-get install iptables-persistent
sudo netfilter-persistent save
sudo netfilter-persistent reload
  

