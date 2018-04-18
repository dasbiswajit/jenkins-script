#!/bin/bash -xe
logfile=/home/ec2-user/logfile.txt
touch $logfile
chmod 777 $logfile
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> $logfile
user=`whoami`
echo "Executing install_script.sh using user $user" >> $logfile
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> $logfile
echo "proxy setup" >> $logfile
echo 'export {http,https}_proxy="vpce-0433981369c08476d-oy16n0if.vpce-svc-06204172f41f7e867.eu-west-1.vpce.amazonaws.com:3128"' | sudo tee -a /etc/bashrc
source /etc/bashrc
echo "running yum update...." >> $logfile
yum update -y >> $logfile
echo "installing python-setuptools...." >> $logfile
yum install -y python-setuptools >> $logfile
echo "installing wget..." >> $logfile
yum install -y wget >> $logfile
echo "installing aws-cfn-bootstrap-latest..." >> $logfile
mkdir -p /opt/aws/bin >> $logfile
wget https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz >> $logfile
easy_install --script-dir /opt/aws/bin aws-cfn-bootstrap-latest.tar.gz >> $logfile
sleep 20
echo "installing nfs-utils.x86_64" >> $logfile
sudo yum install nfs-utils.x86_64 -y >> $logfile
sudo yum install unzip -y >> $logfile
sudo yum install java -y >> $logfile
sleep 10
echo "installing Chef" >> $logfile 
sudo wget https://packages.chef.io/files/stable/chefdk/2.5.3/el/7/chefdk-2.5.3-1.el7.x86_64.rpm >> $logfile
rpm -ivh chefdk-2.5.3-1.el7.x86_64.rpm >> $logfile 
echo "configure Chef. Creating chefdir." >> $logfile 
echo "-------------------------------------------"
mkdir  /opt/chefdk/chefdir/ >> $logfile 
mkdir  /opt/chefdk/chefdir/cookbooks >> $logfile 
cd /opt/chefdk/chefdir/cookbooks >> $logfile 
echo "Info: Downloading the Git repository tagged with v1.0.1" >> $logfile
git clone https://github.com/dasbiswajit/jenkins-cookbook.git
sudo export PATH=$PATH:/opt/chefdk/chefdir/
echo "Adjust chef code here" >> $logfile 
echo "Info: Generating master storage (EFS storage)..." >> $logfile  
efsid=$1      
echo "EFSID: $efsid"
efsid=$efsid'.efs.eu-west-1.amazonaws.com'  
echo "Info:: efsid value: $efsid" >> $logfile        
echo "Info:: Creating jenkins directory./var/lib/jenkins." >> $logfile
mkdir /var/lib/jenkins >> $logfile 
echo "Info:: fstab entry" >> $logfile
echo "$efsid:/ /var/lib/jenkins nfs4 defaults,vers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2  0  0" >> /etc/fstab
sleep 60
echo "Info:: Mounting the efs volume" >> $logfile
mount -a
echo "Info:: EFS volume has been mounted successfully" >> $logfile
echo "Info:: AWS CLI Installation" >> $logfile
easy_install pip | tee -a $logfile
pip install awscli | tee -a $logfile
echo "Info:: AWS CLI has been installed successfully" >> $logfile

