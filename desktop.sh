

sudo apt install xubuntu-desktop -y
sudo apt install xrdp -y


sudo adduser xrdp ssl-cert  
# edit /etc/xrdp/startwm
# replace /etc/X11/Xsession lines with
# startxfce4
sudo systemctl restart xrdp
sudo ufw allow 3389

passwd ubuntu

