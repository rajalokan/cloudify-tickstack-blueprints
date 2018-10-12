#! /bin/bash -e

ctx logger info "Bootstrapping TickStack node"
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
PASSWORD='rajalokan'
influx
CREATE USER "rajalokan" WITH PASSWORD 'rajalokan' WITH ALL PRIVILEGES
exit
# Enable auth in influxdb
sudo sed -i '/^\[http\]$/,/^\[/ s/^  # auth-enabled =.*/  auth-enabled = true/' /etc/influxdb/influxdb.conf

ctx logger info "Installing and Configuring Kapacitor"
sudo yum install -y kapacitor
# Update influxdb details in kapacitor config
sudo sed -i '/^\[\[influxdb\]\]$/,/^\[/ s/^  username =.*/  username = \"rajalokan\"/' /etc/kapacitor/kapacitor.conf
sudo sed -i '/^\[\[influxdb\]\]$/,/^\[/ s/^  password =.*/  password = \"rajalokan\"/' /etc/kapacitor/kapacitor.conf
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
sudo sed -i '/^\[\[outputs.influxdb\]\]$/,/^\[/ s/^  # username =.*/  username = \"rajalokan\"/' /etc/telegraf/telegraf.conf
sudo sed -i '/^\[\[outputs.influxdb\]\]$/,/^\[/ s/^  # password =.*/  password = \"rajalokan\"/' /etc/telegraf/telegraf.conf
sudo systemctl start telegraf
