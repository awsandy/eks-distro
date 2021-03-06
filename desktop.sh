

sudo apt-get install xubuntu-desktop -qq
sudo apt-get install xrdp -qq

sudo adduser xrdp ssl-cert  
# edit /etc/xrdp/startwm
# replace /etc/X11/Xsession lines with
# startxfce4
sudo systemctl restart xrdp
sudo ufw allow 3389

passwd ubuntu

