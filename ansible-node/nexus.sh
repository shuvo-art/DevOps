apt update
apt install openjdk-11-jre -y
apt install net-tools -y

cd /opt
wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
tar -xvzf latest-unix.tar.gz

adduser nexus
chown -R nexus:nexus /opt/nexus-3*
chown -R nexus:nexus /opt/sonatype-work

vim nexus-3*/bin/nexus.rc
run_as_user="nexus"

su - nexus
/opt/nexus-3*/bin/nexus start

ps aux | grep nexus
netstat -plnt | grep 8081

