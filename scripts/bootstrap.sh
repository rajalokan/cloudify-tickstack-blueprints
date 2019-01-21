#! /bin/bash -e

ctx logger info "Bootstrapping Tickstack"
sudo apt install -y wget || sudo yum install -y wget

if [[ ! -f /tmp/sclib.sh ]]; then
    wget -q https://raw.githubusercontent.com/rajalokan/okanstack/master/sclib.sh -O /tmp/sclib.sh
fi
source /tmp/sclib.sh

# Preconfigure the instance
_preconfigure_instance tickstack

ctx logger info "Adding influx repo"
cat <<EOF | sudo tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository - RHEL \$releasever
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOF

ctx logger info "Installing and Configuring influxdb"
sudo yum install -y influxdb
sudo systemctl start influxdb
sleep 3
USERNAME='rajalokan'
PASSWORD='rajalokan'
influx -execute "CREATE USER \"${USERNAME}\" WITH PASSWORD '${PASSWORD}' WITH ALL PRIVILEGES"
# Enable auth in influxdb
sudo sed -i '/^\[http\]$/,/^\[/ s/^  # auth-enabled =.*/  auth-enabled = true/' /etc/influxdb/influxdb.conf
sudo systemctl restart influxdb

ctx logger info "Installing and Configuring Kapacitor"
sudo yum install -y kapacitor
# Update influxdb details in kapacitor config
sudo sed -i "/^\[\[influxdb\]\]$/,/^\[/ s/^  username =.*/  username = \'${USERNAME}\'/" /etc/kapacitor/kapacitor.conf
sudo sed -i "/^\[\[influxdb\]\]$/,/^\[/ s/^  password =.*/  password = \'${PASSWORD}\'/" /etc/kapacitor/kapacitor.conf
sudo systemctl daemon-reload
sudo systemctl start kapacitor

ctx logger info "Installing and Configuring Chronograf"
sudo yum install -y chronograf
sudo systemctl start chronograf

ctx logger info "Installing and Configuring Telegraf"
sudo yum install -y telegraf
# Update influx db config in telegraf
sudo sed -i '/^\[\[outputs.influxdb\]\]$/,/^\[/ s/^  # urls =.*http.*/  urls = \[\"http:\/\/localhost:8086\"\]/' /etc/telegraf/telegraf.conf
sudo sed -i '/^\[\[outputs.influxdb\]\]$/,/^\[/ s/^  # database =.*/  database = \"telegraf\"/' /etc/telegraf/telegraf.conf
sudo sed -i "/^\[\[outputs.influxdb\]\]$/,/^\[/ s/^  # username =.*/  username = \'${USERNAME}\'/" /etc/telegraf/telegraf.conf
sudo sed -i "/^\[\[outputs.influxdb\]\]$/,/^\[/ s/^  # password =.*/  password = \'${PASSWORD}\'/" /etc/telegraf/telegraf.conf
sudo systemctl start telegraf

# Install Grafana
ctx logger info "Installing and Configuring Grafana"
wget https://dl.grafana.com/oss/release/grafana-5.4.3-1.x86_64.rpm -O /tmp/grafana.rpm
cd /tmp/ && sudo yum localinstall -y grafana.rpm
sudo systemctl start grafana-server
