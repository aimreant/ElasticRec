# for root
export LC_ALL=C

apt-get install -y build-essential checkinstall
apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
cd /opt
wget https://www.python.org/ftp/python/3.6.5/Python-3.6.5.tgz
tar -xvf Python-3.6.5.tgz
cd Python-3.6.5/

./configure
make
make install

python3 -m pip install mlflow -i https://pypi.tuna.tsinghua.edu.cn/simple

apt-get install -y openjdk-8-jre-headless openjdk-8-jdk-headless

addgroup hadoop
adduser -ingroup hadoop hadoop
sudo adduser hadoop sudo

cd /usr/local
wget https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz
tar -zxvf hadoop-3.2.1.tar.gz -C /usr/local/
chown -R hadoop:hadoop hadoop-3.2.1/

cur_hostname=$(hostname)
cur_inner_ip=ip=$(ip addr |grep inet |grep -v inet6 |grep eth0 |awk '{print $2}' |awk -F "/" '{print $1}')
echo "$ip $cur_hostname" >> /etc/hosts

# for hadoop
su hadoop
cd /usr/local/hadoop-3.2.1

echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> ~/.bash_profile
echo 'export PATH=$PATH:/usr/local/hadoop-3.2.1/bin' >> ~/.bash_profile
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> etc/hadoop/hadoop-env.sh

ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

mkdir input && cd input
echo "hello world" > test1.txt
echo "hello hadoop" > test2.txt
cd ..
./bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-3.2.1.jar wordcount input output
cat output/*

sed "s/localhost/$cur_inner_ip/g" core-site.xml.template > core-site.xml
cp -f core-site.xml etc/hadoop/core-site.xml
cp -f hdfs-site.xml etc/hadoop/hdfs-site.xml

sed "s/localhost/$cur_inner_ip/g" yarn-site.xml.template > yarn-site.xml
cp -f yarn-site.xml etc/hadoop/yarn-site.xml

./bin/hdfs namenode -format

./sbin/start-all.sh

jps
