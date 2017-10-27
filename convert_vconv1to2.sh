#!/bin/bash
# versione script installazione autoatica: 2.0
# Autore: Luca C.
# Ultima modivica: 17/5/2017

# aggiorno il sistema
apt-get update
apt-get -y install vim screen aptitude samba git  dfc nmon libssl-dev openssh-server  libav-tools  libavcodec54  apache2 php5 make openssh-server
apt-get upgrade -y
locale-gen en_US en_US.UTF-8 it_IT
dpkg-reconfigure locales

# correggi ssh server
#sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
#service ssh restart

# installo n2n
#cd /tmp
#git clone https://github.com/lukablurr/n2n_v2_fork
#cd n2n_v2_fork
#sudo make
#sudo make install
#cd


# elimino tutta la parte relativa a vconv1

rm -rf /CONDIVISA/*
rm -rf /vconv
update-rc.d vconv disable
rm -rf /var/www/html/*

# preparo il programma
#mkdir /scripts
cd /
git clone https://github.com/bizzarrone/vconv2.git
#mv /scripts/vconv/avconvluca.sh /scripts/
touch /vconv2/vconv2.log
chmod 777 /vconv2/parametri.txt

# CREAZIONE Share di rete
mkdir /CONDIVISA
cd /CONDIVISA
mkdir video-IN  logo-IN video-OUT
chmod -R 777 /CONDIVISA/

# creare servizio all'avvio
mv /vconv2/edge  /etc/init.d/
mv /vconv2/vconv2 /etc/init.d/
update-rc.d edge defaults
update-rc.d edge enable
update-rc.d vconv2 defaults
update-rc.d vconv2 enable
yyupdate-rc.d apache2 defaults
yyupdate-rc.d apache2 enable 

# installare le webpages
cd /
wget https://github.com/bizzarrone/vconv2/raw/master/vconv2web.tar.gz
cd / ; tar xvzf vconv2web.tar.gz
rm /vconv2web.tar.gz
chown -R www-data:www-data  /var/www/html
rm /var/www/html/index.html

