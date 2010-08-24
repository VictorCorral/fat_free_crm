#
# Capistrano recipes for cold deployments
#
# Usage (add the following to your deploy.rb):
#
#    load 'recipes/stack'
#    set :mysql_version, "2.8.1" (if different to default below)
#    set :gems_to_install, []
#    ...
#
#    Then just run "cap deploy:cold" and this stack will hook into it
#
# Depends on prompt.rb
#

# 
# Other useful commands
#
# cap stack - install operating system packages and setup rails folders
# cap update:os - runs yum update
# cap update:passenger - updates passenger
# cap files:set_permissions - sets permissions
#

#
# Defaults
#  - should be overriden in deploy.rb but MUST come after load 'recipes/stack'
#
set :yum_packages_to_install, "aspell gcc gcc-c++ bzip2-devel zlib-devel make openssl-devel httpd-devel \
libstdc++-devel freeimage-devel clamav-devel mysql-devel readline-devel ruby ruby-rdoc ruby-ri ruby-irb \
rubygems ruby-devel mod_ssl git" # others include "memcached sphinx"
set :gems_to_install, {
  'rails' => '2.3.8',
  'rake' => '0.8.7',
}
set :mysql_gem_version, '2.8.1'

namespace :stack do

  # Override this if you don't want particular stack items
  desc "Setup operating system and rails environment"
  task :default do
    update.os
    install.default
    files.setup
    files.create_database_yml
    files.set_permissions
  end

end

namespace :install do

  desc "Setup operating system and rails environment"
  task :default do
    base
    mysql_gem
    gems
    httpd
  end

  desc "Install base packages"
  task :base do
    run "yum clean all"
    run "yum -y install #{yum_packages_to_install}"
  end

  desc "Install required gems"
  task :gems do
    gems_to_install.each do |name, version|
      run "gem install #{name} --no-rdoc --no-ri#{' --version '+ version unless (version.nil? or version == '') }"
    end
  end
  
  desc "Install required Gems"
  task :mysql_gem do
    run "gem install mysql #{'--version ' + mysql_gem_version if !mysql_gem_version.nil?}" + ' -- --with-mysql-config'
  end

  desc "Install Apache"
  task :httpd do
    run "yum -y install httpd httpd-devel apr apr-devel apr-util apr-util-devel"
    run "if [ `uname -m` == 'x86_64' ]; then yum -y remove apr-devel.i386 apr-util-devel.i386 httpd-devel.i386; fi"
    run "chkconfig httpd on"
    run "if [ -f /etc/httpd/conf.d/proxy_ajp.conf ]; then rm -rf /etc/httpd/conf.d/proxy_ajp.conf; fi"
  end

end

namespace :update do
  
  desc "Update Operating System"
  task :os do
    run "yum -y update"
  end
 
end

namespace 'files' do

  desc "Create shared directories"
  task :setup do
    run "if [ ! -d #{deploy_to}/shared ]; then mkdir --parents #{deploy_to}/shared; fi"
    run "if [ ! -d #{deploy_to}/shared/pids ]; then mkdir --parents #{deploy_to}/shared/pids; fi"
    run "if [ ! -d #{deploy_to}/shared/log ]; then mkdir --parents #{deploy_to}/shared/log; fi"
    run "if [ ! -d #{deploy_to}/shared/.ruby_inline ]; then mkdir --parents #{deploy_to}/shared/.ruby_inline; fi"
    run "if [ ! -d #{deploy_to}/shared/system ]; then mkdir --parents #{deploy_to}/shared/system; fi"
    run "if [ ! -d #{deploy_to}/releases ]; then mkdir --parents #{deploy_to}/releases; fi"
  end
  
  desc "Setting proper permissions on shared directory"
  task :set_permissions do
    # shared folder
    run "chown -R apache:apache #{deploy_to}/shared/"
    run "chmod -R 755 #{deploy_to}/shared/"
    # during deployments
    run "if [ #{release_path}/ ]; then chown -R apache:apache #{release_path}/; fi"
    run "if [ #{release_path}/ ]; then chmod -R 755 #{release_path}/; fi"
  end

  desc "Create the database.yml file"
  task :create_database_yml do
    prompt_with_default("Database name", :db_name, "gh3_preview")
    prompt_with_default("Database username", :db_username, "gh3_preview")
    prompt_with_default("Database password", :db_password, "gh3_preview_password")
    prompt_with_default("Database host", :db_host, "localhost")
    prompt_with_default("Database port", :db_port, "3306")
    database_yml = <<-EOF
production:
  adapter: mysql
  encoding: utf8
  database: #{db_name}
  username: #{db_username}
  password: #{db_password}
  host:     #{db_host}
  port:     #{db_port}
  pool:     10
  timeout:  5
    EOF
    put database_yml, "#{deploy_to}/shared/database.yml"
    # TODO: extend this to add mysql user/password with these details
    #run("grep \"PASSWORD(\" /etc/mysql.d/grants.sql | cut -d \"'\" -f 6") do |channel, stream, data|
    #  set :pass, data
    #end
    #run "echo #{pass}"
    # now login and set the new user password
    #CREATE DATABASE <db_name>;
    #
  end
  
  desc "Ensure the database.yml file is linked to current/config"
  task :symlink_database_yml do
    run "ln -sf #{deploy_to}/shared/database.yml  #{release_path}/config/database.yml"
  end
  
end

#
# Hooks
#
before "deploy:cold", "stack"
after "deploy:update_code", "files:symlink_database_yml"
before "deploy:symlink", "files:set_permissions"
