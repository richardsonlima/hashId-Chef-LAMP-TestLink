#!/bin/bash

#  Created by Richardson Lima - contato@richardsonlima.com.br

# set -x

echo -e "\033[1;34m [+] Install GIT Client \033[m";
sudo apt-get update &&  sudo apt-get install git-core lynx -y

echo -e "\033[1;34m [+] Checking if chef  exists \033[m";
if [ ! -f "/usr/bin/chef-solo" ]; then
echo -e "\033[1;31m [+] Chef Solo not found \033[m";
echo -e "\033[1;34m [+] Installing Chef Solo \033[m";
curl -L https://www.opscode.com/chef/install.sh | sudo bash
>> ~/.bash_profile && source ~/.bash_profile
sudo chef-solo -v
else
  echo -e "\033[1;34m [+] Chef OK \033[m";

fi

echo -e "\033[1;34m [+] Download and configure CHEF-REPO structure \033[m";
wget http://github.com/opscode/chef-repo/tarball/master
tar -zxvf master
sudo mkdir -p /opt/chef-repo
sudo mv chef-chef-repo-*/ /opt/chef-repo
sudo mkdir /opt/chef-repo/.chef

echo -e "\033[1;34m [+] Configure cookbook \033[m";
sudo touch /opt/chef-repo/.chef/knife.rb
sudo chown `whoami`: /opt/chef-repo/.chef/knife.rb
sudo cat << EOF > /opt/chef-repo/.chef/knife.rb
cookbook_path [ '/opt/chef-repo/cookbooks' ]
EOF
sudo chown root: /opt/chef-repo/.chef/knife.rb

echo -e "\033[1;34m [+] Configure solo.rb \033[m";
sudo touch /opt/chef-repo/solo.rb
sudo chown `whoami`: /opt/chef-repo/solo.rb
sudo cat << EOF > /opt/chef-repo/solo.rb
file_cache_path "/opt/chef-solo"
cookbook_path "/opt/chef-repo/cookbooks"
EOF
sudo chown root: /opt/chef-repo/solo.rb

echo -e "\033[1;34m [+] Downloading cookbook \033[m";
sudo git clone https://github.com/richardsonlima/hashId-Chef-LAMP-TestLink.git -l /opt/chef-repo/cookbooks/testlink

echo -e "\033[1;34m [+] Creating your json\033[m";
sudo touch /opt/chef-repo/testlink.json
sudo chown `whoami`: /opt/chef-repo/testlink.json
sudo cat << EOF > /opt/chef-repo/testlink.json
  { "run_list": [ "recipe[testlink]" ] }
EOF
sudo chown root:  /opt/chef-repo/testlink.json

echo -e "\033[1;34m [+] Execute CHEF-SOLO \033[m";
sudo /usr/bin/chef-solo -c /opt/chef-repo/solo.rb -j /opt/chef-repo/testlink.json

#echo -e "\033[1;34m [+] Enabling default site end reload apache2 \033[m";
#sudo a2ensite 000-default.conf && sudo service apache2 reload

echo -e "\033[1;34m [+] See service status \033[m";
ps -ef | grep apache |grep -v grep && ps -ef|grep mysql|grep -v grep

echo -e "\033[1;34m [+] Accessing Apache Web Interface \033[m";
lynx http://localhost/index.php
