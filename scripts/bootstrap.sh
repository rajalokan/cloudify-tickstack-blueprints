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

ctx logger info "Installing and Configuring Kapacitor"
sudo yum install -y kapacitor
# Update influxdb details in kapacitor config
sudo systemctl daemon-reload
sudo systemctl start kapacitor

ctx logger info "Installing and Configuring Chronograf"
sudo yum install -y chronograf

ctx logger info "Installing and Configuring Telegraf"
sudo yum install -y telegraf
# Update influx db config in telegraf
sudo systemctl start telegraf
