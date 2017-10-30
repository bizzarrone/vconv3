#!/bin/bash
# versione script installazione autoatica: 2.0
# Autore: Luca C.
# Ultima modivica: 27/10/2017

# aggiorno il sistema
apt-get update
apt-get -y install apache2 php7.0
apt-get -y install vim screen aptitude samba git dfc nmon libssl-dev openssh-server  libav-tools libavcodec-ffmpeg56 make openssh-server
apt-get upgrade -y
locale-gen en_US en_US.UTF-8 it_IT
#dpkg-reconfigure locales

# correggi ssh server
#sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
#echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
service ssh restart

# installo n2n
cd /tmp
git clone https://github.com/lukablurr/n2n_v2_fork
cd n2n_v2_fork
sudo make
sudo make install
cd

# preparo il programma
#mkdir /scripts
cd /
git clone https://github.com/bizzarrone/vconv3.git
touch /vconv3/vconv3.log
chmod 777 /vconv3/parametri.txt

# CREAZIONE Share di rete
mkdir /CONDIVISA
cd /CONDIVISA
mkdir video-IN  logo-IN video-OUT
chmod -R 777 /CONDIVISA/

# configuro SAMBA
echo  "[CONDIVISA] " >> /etc/samba/smb.conf
echo  " comment = VIDEO " >> /etc/samba/smb.conf
echo  " path = /CONDIVISA" >> /etc/samba/smb.conf
echo  " browseable = yes" >> /etc/samba/smb.conf
echo  " read only = no" >> /etc/samba/smb.conf
echo  " create mask = 0777" >> /etc/samba/smb.conf
echo  " writable = yes" >> /etc/samba/smb.conf
echo  " guest ok = yes" >> /etc/samba/smb.conf

# creare servizio all'avvio
mv /vconv3/vconv3.service /lib/systemd/system/vconv3.service
systemctl enable vconv3.service
#update-rc.d edge defaults
#update-rc.d edge enable
systemctl enable apache2
systemctl start apache2

# installare le webpages
cd /
wget https://github.com/bizzarrone/vconv3/raw/master/vconv3web.tar.gz
cd / ; tar xvzf vconv3web.tar.gz
rm /vconv3web.tar.gz
chown -R www-data:www-data  /var/www/html
rm /var/www/html/index.html
reboot
