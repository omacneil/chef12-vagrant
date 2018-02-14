VAGRANTFILE_API_VERSION = '2'
PROJECT_NAME            = '/' + File.basename(Dir.getwd)
YAML_CONFIG_FILE        = 'Vagrantfile.yaml'

# This is a generic Vagrantfile that can be used without modification in
# a variety of situations. Hosts and their properties are specified in
# Vagrantfile.yaml .
#
# based on:
#             https://github.com/bertvv/ansible-skeleton/ 

require 'rbconfig'
require 'yaml'
require 'fileutils'

DEFAULT_BASE_BOX = 'ubuntu/xenial64'

#  options for the network interface configuration.
# - ip (default = DHCP)
# - netmask (default value = 255.255.255.0
# - mac
# - auto_config (if false, Vagrant will not configure this network interface
# - intnet (if true, an internal network adapter will be created instead of a
#   host-only adapter)
def network_options(host)
  options = {}

  if host.key?('ip')
    options[:ip] = host['ip']
    options[:netmask] = host['netmask'] ||= '255.255.255.0'
  else
    options[:type] = 'dhcp'
  end
  
  options[:name]               = 'vboxnet0'
  options[:adapter]            = 2
  options[:mac]                = host['mac'].gsub(/[-:]/, '') if host.key?('mac')
  options[:auto_config]        = host['auto_config'] if host.key?('auto_config')
  options[:virtualbox__intnet] = true if host.key?('intnet') && host['intnet']
  options
end

def custom_synced_folders(vm, host)
  return unless host.key?('synced_folders')
  
  folders = host['synced_folders']
  folders.each do |folder|
    vm.synced_folder folder['src'], folder['dest'], folder['options']
  end
end

#  be sure the vboxnet0 virtualbox network exists
vboxnet0_check = `vboxmanage list  hostonlyifs |grep vboxnet0`
net_installed  = (vboxnet0_check=~/Name:.*vboxnet0/)
if not net_installed 
  puts 'vboxnet missing, adding...'
  result=`vboxmanage hostonlyif create`
  puts "result: #{result}"
else
  puts 'vboxnet0 present, no need to create it, doing nothing'
end

ssh_key = "#{ENV['HOME']}/.vagrant.d/insecure_private_key"
if (FileTest.readable?(ssh_key))
   puts "copying #{ssh_key} so vagrant box ssh to each other"
   FileUtils.cp ssh_key, 'setup'
else    
   STDERR.puts "WARNING: #{ssh_key} not found or not readable"
   STDERR.puts 'WARNING: there may be issues with guest to guest ssh'
end
 
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  #  so we can use the ssh key:
  #      $HOME/.vagrant.d/insecure_private_key 
  # ... for everything including guest to guest ssh
  config.ssh.insert_key = false
  
  hosts = YAML.load_file(YAML_CONFIG_FILE)
  hosts.each do |host|
    config.vm.define host['name'] do |node|
      node.vm.box = host['box'] ||= DEFAULT_BASE_BOX
      node.vm.box_url = host['box_url'] if host.key? 'box_url'
      
      node.vm.hostname = host['name']
      node.vm.network :private_network, network_options(host)
      custom_synced_folders(node.vm, host)

      node.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", host['memory'] ||=1024 ]
      end

    if host.has_key?('shell_scripts_always')
          scripts=host['shell_scripts_always']
          scripts.each do |script|
            node.vm.provision "shell", path: script['path'], name: script['path'], run: 'always'
          end
    end
    
    if host.has_key?('shell_scripts_on_create')
          scripts=host['shell_scripts_on_create']
          scripts.each do |script|
            node.vm.provision "shell", path: script['path'], name: script['path'], run: 'always'
          end
    end

    end     # do |node|
  end       # do |host|
end

# -*- mode: ruby -*-
# vi: ft=ruby :

