#build DWC, copy into 192.168.1.{ip} and run deploy-dwc script onboard

$ip=$args[0]

#npm run build
scp .\dist\DuetWebControl-SBC.zip pi@192.168.1.${ip}:/tmp
ssh pi@192.168.1.${ip} "
    rm -rf /tmp/dwc &&
    mkdir /tmp/dwc &&
    unzip /tmp/DuetWebControl-SBC.zip -d /tmp/dwc &&
    sudo -u dsf cp -rv /tmp/dwc/* /opt/dsf/dwc/
    sudo systemctl restart duetwebserver
"
