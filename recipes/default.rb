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

app_dir = "/var/www/html/testlink"
db = "testlink"
db_pass = "m6w2msmV"
db_user = "testlink_usr"

directory app_dir do
  mode "0644"
  group "root"
  owner "root"
  action :create
end

execute "File extraction and chown" do
  user "root"
  command "tar -xzf /tmp/testlink-1.9.14.tar.gz -C #{app_dir} &&
           chown -R root:root #{app_dir}/testlink-1.9.14"
end
execute "File moving" do
  user "root"
  command "mv #{app_dir}/testlink-1.9.14/* #{app_dir}"
end
execute "Perm/access fixing" do
  user "root"
  command "chown -R root:root #{app_dir} &&
           chmod -R 777 #{app_dir}/upload_area &&
           chmod -R 777 #{app_dir}/logs &&
           rm -rf #{app_dir}/testlink-1.9.14"
end

user "sysops" do
  action :create
  gid "sudo"
  system true
end

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
    mysql -uroot -pP11xhDNhs4hmw -e "create database testlink;"
    mysql -u root -proot -e "CREATE USER #{db_user};"
    mysql -uroot -pP11xhDNhs4hmw -e "grant SELECT, INSERT, UPDATE, DELETE on testlink.* to testlink_usr@localhost identified by 'm6w2msmV';"
    mysql -u root -proot #{db} < #{app_dir}/install/sql/mysql/testlink_create_tables.sql &&
    mysql -u root -proot #{db} < #{app_dir}/install/sql/mysql/testlink_create_default_data.sql
  EOH
end

cookbook_file "#{app_dir}/config_db.inc.php" do
  source "config_db.inc.php"
  mode 0755
  owner "root"
  group "root"
end

execute "remove install dir" do
  user "root"
  command "rm -rf #{app_dir}/install"
end

execute "Set app dir perms" do
  user "root"
  command "chown -R www-data:www-data #{app_dir} &&
           chmod -R 775 #{app_dir}"
end

cookbook_file "/etc/services" do
  source "services"
  mode 0644
  owner "root"
  group "root"
end

cookbook_file "/tmp/testlink-1.9.14.tar.gz" do
  source "testlink-1.9.14.tar.gz"
  mode 0755
  owner "root"
  group "root"
end

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

bash "create_dir_apache" do
  user "root"
  ignore_failure true
  code <<-EOH
   chown -R www-data:www-data /var/www/html/
  EOH
end
