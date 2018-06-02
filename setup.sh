#!/bin/bash

export PROMETHEUS_VERSION="2.2.1"
export CONFD_VERSION=
export NODEX_VERSION="0.16.0"

# run updates
echo "updating..."
apt-get update && apt-get -y upgrade

# create users
echo "creating users..."
useradd --no-create-home --shell /bin/false prometheus
useradd --no-create-home --shell /bin/false node_exporter

# create prometheus directories with correct permissions
echo "creating prometheus directories..."
mkdir /etc/prometheus
mkdir /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

# download prometheus
echo "downloading promethus..."
cd ~
wget "https://github.com/prometheus/prometheus/releases/download/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz"
tar -xvzf "prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz"

# install prometheus
echo "installing prometheus..."
mv "prometheus-$PROMETHEUS_VERSION.linux-amd64/prometheus" /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus

# install prometheus cli
echo "installing prometheus cli..."
mv "prometheus-$PROMETHEUS_VERSION.linux-amd64/promtool" /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/promtool

# copy prometheus directories to correct locations
echo "copying prometheus console directories..."
cp -r "prometheus-$PROMETHEUS_VERSION.linux-amd64/consoles" /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus/consoles
cp -r "prometheus-$PROMETHEUS_VERSION.linux-amd64/console_libraries" /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus/console_libraries

# install node_exporter
echo "installing node_exporter..."
wget "https://github.com/prometheus/node_exporter/releases/download/v$NODEX_VERSION/node_exporter-$NODEX_VERSION.linux-amd64.tar.gz"
tar -xvzf "node_exporter-$NODEX_VERSION.linux-amd64.tar.gz"
sudo mv "node_exporter-$NODEX_VERSION.linux-amd64/node_exporter" /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter
rm -rf "node_exporter-$NODEX_VERSION.linux-amd64.tar.gz" "node_exporter-$NODEX_VERSION.linux-amd64"

# update systemd
echo "enabling services..."
systemctl daemon-reload
systemctl enable prometheus.service
systemctl enable node_exporter.service

# Install confd
echo "installing confd..."
wget -O ~/confd "https://github.com/kelseyhightower/confd/releases/download/v$CONFD_VERSION/confd-$CONFD_VERSION-darwin-amd64"
mv /home/app/confd /usr/local/bin/confd
chmod +x /usr/local/bin/confd

# cleanup
echo "cleanup..."
rm -rf "prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz" "prometheus-$PROMETHEUS_VERSION.linux-amd64"