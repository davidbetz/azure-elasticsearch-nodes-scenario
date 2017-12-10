# MIT License

# Copyright(c) 2016 David Betz

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

export COUNT=$1
export SCRIPT_BASE=$2
export NAME=$3

yum install java-1.8.0-openjdk.x86_64 -y

rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch

cat > /etc/yum.repos.d/elasticsearch.repo << EOF
[elasticsearch-2.1]
name=Elasticsearch repository for 2.x packages
baseurl=http://packages.elastic.co/elasticsearch/2.x/centos
gpgcheck=1
gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1
EOF

yum install elasticsearch -y

systemctl start firewalld
systemctl enable firewalld
sed "s/\"80\"/\"9200\"/;s/WWW (HTTP)/Elasticsearch/;/<description>.*/d" /usr/lib/firewalld/services/http.xml > /etc/firewalld/services/elasticsearch.xml
sed "s/\"80\"/\"9300-9400\"/;s/WWW (HTTP)/Elasticsearch Node/;/<description>.*/d" /usr/lib/firewalld/services/http.xml > /etc/firewalld/services/elasticsearch-node.xml
firewall-cmd --permanent --zone=public --add-interface=eth0
firewall-cmd --reload
firewall-cmd --permanent --add-service=elasticsearch --zone=public
firewall-cmd --reload

rm -f /var/tmp/firewall-update.sh
for n in $(seq 1 $COUNT);
do echo firewall-cmd --permanent --add-rich-rule=\'rule family=\"ipv4\" source address=\"10.$(($(($n*16))+1)).0.4/16\" service name=\"elasticsearch-node\" accept\' --zone=public >> /var/tmp/firewall-update.sh
done
cat /var/tmp/firewall-update.sh
chmod +x /var/tmp/firewall-update.sh
/var/tmp/firewall-update.sh
rm -f /var/tmp/firewall-update.sh

firewall-cmd --reload

export PUBLIC_IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

cat > /etc/elasticsearch/elasticsearch.yml << EOF
cluster.name: my-search-cluster
node.name: search-$NAME
network.host: $PUBLIC_IP
#transport.publish_host: MY_PUBLIC_AZURE_IP_HERE
discovery.zen.ping.multicast.enabled: false
discovery.zen.ping.unicast.hosts: [$(for n in $(seq 1 $COUNT); do echo "\"10.$(($(($n*16))+1)).0.4\""; done | tr '\n', ',' | sed "s/,$//")]
EOF

systemctl start elasticsearch
systemctl enable elasticsearch

cd /usr/share/elasticsearch
bin/plugin install mobz/elasticsearch-head

wget $SCRIPT_BASE/create_data_generation_setup.sh -O /root/create_data_generation_setup.sh
chmod +x /root/create_data_generation_setup.sh
/root/create_data_generation_setup.sh $SCRIPT_BASE