#!/bin/bash
# Script per aggiornamnto programma avconv

rm -rf /scripts
mv -f /CONDIVISA /CONDIVISA-OLD
rm -rf /vconv2
mv -f /etc/init.d/rc.local /etc/init.d/rc.local.old
rm -rf /var/www/html 
cd
rm -f install_vconv2.sh*
wget https://raw.githubusercontent.com/bizzarrone/vconv2/master/install_vconv2.sh
sh install_vconv2.sh 
