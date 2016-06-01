#
# Cookbook Name::  testlink
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "build-essential" do
  action :install
end

package "apache2" do
  action :install
end

package "php5" do
  action :install
end

package "php5-curl" do
  action :install
end

package "php5-dev" do
  action :install
end

package "php5-mysql" do
  action :install
end

package "php5-gd" do
  action :install
end

package "php5-xmlrpc" do
  action :install
end

package "libapache2-mod-php5" do
  action :install
end

package "apache2-mpm-prefork" do
action :install
end

######

#group "" do
#  action :create
#end

user "sysops" do
  action :create
  gid "sudo"
  system true
end

######

#mysql server usuario: root / senha: P11xhDNhs4hmw
bash "install_mysql_server" do
  user "root"
  ignore_failure true
  code <<-EOH
   (echo "mysql-server-5.5 mysql-server/root_password password P11xhDNhs4hmw" | debconf-set-selections && echo "mysql-server-5.5 mysql-server/root_password_again password P11xhDNhs4hmw" | debconf-set-selections && apt-get -y --force-yes install mysql-server-5.5)
  EOH
end

bash "create_database" do
  user "root"
  ignore_failure true
  code <<-EOH
    mysql -uroot -pP11xhDNhs4hmw -e "create database testlinkdb;"
    mysql -uroot -pP11xhDNhs4hmw -e "grant all privileges on testlinkdb.* to teamtestlink@localhost identified by 'zwsIFHa3ZLd';"
  EOH
end

#bash "create_database" do
#  user "root"
#  ignore_failure true
#  code <<-EOH
#    mysql -uroot -pP11xhDNhs4hmw -e "create database webapp-01-db;"
#    mysql -uroot -pP11xhDNhs4hmw -e "grant all privileges on webapp-01-db.* to teamwebapp01@localhost identified by 'zwsIFHa3ZLd';"
#    mysql -u teamwebapp01 -pzwsIFHa3ZLd webapp-01-db < /srv/dbs/database-webapp-01/mysql/data-0001.sql
#  EOH
#end

#bash "install_app" do
#  user "root"
#  code <<-EOH
#   (cd /srv/webapp-01/ && ./configure --enable-server --enable-agent --with-mysql && make install)
#  EOH
#end

cookbook_file "/etc/services" do
  source "services"
  mode 0644
  owner "root"
  group "root"
end

#cookbook_file "/usr/local/etc/webapp-01.conf" do
#  source "webapp-01.conf"
#  mode 0644
#  owner "root"
#  group "root"
#end

cookbook_file "/etc/php5/apache2/php.ini" do
  source "php.ini"
  mode 0644
  owner "root"
  group "root"
end

cookbook_file "/etc/apache2/sites-available/000-default.conf" do
  source "000-default.conf"
  mode 0644
  owner "root"
  group "root"
end

cookbook_file "/etc/apache2/conf-available/security.conf" do
  source "security.conf"
  mode 0644
  owner "root"
  group "root"
end

apache_site "000-default.conf" do
  enable true
end

service "apache2" do
 action :restart
end

cookbook_file "/var/www/html/index.html" do
  source "index.html"
  mode 0755
  owner "www-data"
  group "www-data"
end

cookbook_file "/var/www/html/index.php" do
  source "index.php"
  mode 0755
  owner "www-data"
  group "www-data"
end

cookbook_file "/var/www/html/info.php" do
  source "info.php"
  mode 0755
  owner "www-data"
  group "www-data"
end



#service "webapp-01-server" do
# action :start
#end

#bash "updaterc" do
#  user "root"
#  ignore_failure true
#  code <<-EOH
#   update-rc.d -f webapp-01-server defaults
#  EOH
#end

#bash "create_dir_apache" do
#  user "root"
#  ignore_failure true
#  code <<-EOH
#   mkdir -p /var/www/html/webapp-01
#   cp -a /srv/webapp-01/frontends/php/* /var/www/html/webapp-01/
#   chown -R www-data:www-data /var/www/html/webapp-01/
#  EOH
#end

bash "create_dir_apache" do
  user "root"
  ignore_failure true
  code <<-EOH
   chown -R www-data:www-data /var/www/html/
  EOH
end
