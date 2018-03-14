# PURPOSE: 
Do as little work as possible to create a vagrant testing/learning setup
for chef version 12 with a chef server, chef workstation and 2 test
boxes running Ubuntu 16.04 LTS Linux.

# LICENSE
GPLv3 , probably a bit grand for such a small project, but there it is.
 
# AUTHOR
Dan MacNeil <dan@omacneil.org>

# FEATURES
1. Get going in 20-55 minutes
1. Connect to the chef server from a HOST OS web browser
1. ssh from one vagrant machine to another without password
1. Everything ready go for knife bootstrap 
1. Chef config is outside the vagrant boxes. You can blow away Vagrant 
   and keep your work/play/tests
1. Easy to add test hosts to the test network (copy/paste YAML, edit 
   machine name)

# REQUIREMENTS
1. Six cores of CPU to devote to vagrant/virtual box 
1. Four Gig of RAM to devote to vagrant/virtual box
1. virtualbox , vagrant and git
1. A Debian/Ubuntu Linux. host OS ( probably optional, see POTENTIAL ISSUES) 

You might get by with < 2G RAM on the chef server and <  1G RAM on the 
chef workstation.  However chef server and chef workstation fail to 
start processes with 1 G of RAM and 512M of RAM

You could edit VagrantFile.yaml to disable cheftest01 and cheftest02 to
save 1 G of RAM and 2 cores

# IMPORTANT WARNING
This setup is too insecure for anything but a host-only network. For 
example, the same insecure ssh key is used everywhere for everything

# tldr; SETUP SUMMARY
1. install vagrant, virtual box and git on your workstation 
1. git pull these setup files from GitHub
1. download .deb files for chef server and chef dev kit for Ubuntu 16.04 
1. vagrant up
1. update /etc/hosts on Host OS
1. wait about 20 minutes on modern hardware
1. start using your chef setup
1. git commit your changes in chef-repo/
1. check for POSSIBLE ISSUES

# SETUP DETAIL

## install vagrant, virtual box and git on your workstation             
```shell
  sudo apt install vagrant git virtualbox 
```
## git pull these setup files from GitHub                               
```shell
  cd <your vagrant directory>
  git clone https://github.com/omacneil/chef12-vagrant.git chef12
```

## download .deb files for chef server and chef dev kit for Ubuntu 16.04 
Get the chef server and chef development kit ubuntu 16.04 .deb files
from https://downloads.chef.io/

You will have to register with the chef corporation to get chef server package. 

Place the (2) .deb files you downloaded in the `setup/` directory 

## vagrant up                                                           
```shell
  cd vagrant-chef12
  vagrant up
```

## update /etc/hosts on Host OS                                         
You don't have to wait for vagrant to finish grinding up the guest boxes

```shell
    # Check if chefserver01, chefworkstation01, cheftest01 , 
    # cheftest02 are already present
    clear
    cat /etc/hosts
      
    # if not add them
    sudo su -c "cat setup/etc_hosts_additions  >> /etc/hosts"
```
## start using your chef setup                                          
### web interface
- username: admin
- password: admin1234
- url:      https://chefserver01   

### ssh 
```shell
    cd < this directory>

 vagrant ssh chefworkstaion01
 
    knife bootstrap --sudo -N chefworkstation01 vagrant@chefworkstation01
    knife bootstrap --sudo -N chefserver01 vagrant@chefserver01
    knife bootstrap --sudo -N cheftest01 vagrant@cheftest01
    knife bootstrap --sudo -N cheftest02 vagrant@cheftest02

    knife node list
    knife ssh '*:*' hostname
```      
## git commit your changes     
/home/vagrant/chef-repo/ is a virtualbox synced folder to 
<your vagrant dir>/chef-repo. You can make changes here that will 
survive `vagrant destroy`

git would be a good way to track and tag your project

# POSSIBLE ISSUES
These problems probably unlikely or unimportant but...

## Too much noise in vagrant output
Before running a vagrant command, reduce the log level from INFO 
to WARN with:
```shell
     export VAGRANT_LOG=warn
```
## ==> chefworkstation01: ERROR: Network Error: getaddrinfo: Name or service not known
We `knife ssl verify` from `chef_workstation_verify` . If we haven't got
/etc/hosts set at this point (and this shouldn't happen!), you should run 
`knife ssl verify` by hand on chefworkstation01 to be sure all is ok.  

## ==> chefworkstation01: <SNIP> aws_route53_record_set.rb:48: warning: constant ::Fixnum is deprecated
## cannot load such file -- fog
These look internal to chef, cosmetic and not our problem. 

## ==> chefworkstation01: [WARN] This is an internal command used by the ChefDK development team.
It is very handy to run the 'internal' validate command to be sure 
everything is setup correctly. If it breaks something, it will break 
it on a install that has none of our work saved. Please ignore this
 message. 

## ERROR loader: Unknown config sources: [
This error seems to come up after moving or renaming the directory 
containing your Vagrantfile  or messing with vagrant plugins. It is 
just a warning. However you can make it go away by removing invalid 
cached vagrant boxes and disabling or removing plugins which also 
include configuration. 

```shell
  # requires you re-install your plugins
  vagrant plugin expunge
  
  # missing boxes get re-downloaded and rebuilt. 
  rm -rf ~/.vagrant.d/boxes/
```
Info about where vagrant looks for config sources is here: 
https://www.vagrantup.com/docs/vagrantfile/#load-order

## Provisioning hangs with bad or missing internet connnection
Maybe (?) the chef-manage plugin for chef server reaches out
to the chef corporation when it is being initalized for the
first time. 

Try to have a working internet connection. 

## Provisioning is not re-entrant
You will get errors and undefined results if you run `vagrant provision`
2 times in a row. Don't do that. Run `vagrant destroy` then `vagrant up`

## Very aggressive about Ubuntu package updates
Every time we bring a vagrant guest box up, we check for and apply Ubuntu
package updates. If you fear change, delay and incompatibility more than
you fear security problems and love bug fixes, edit `Vagrantfile.yaml` 
to disable `setup/apt_update_upgrade`

## tested only with these versions
We're not doing anything complicated, bumping up minor version numbers
should be fine, but if not here's what's known to work: 

- Host OS/workstation: Debian 10 (Buster)
- Ubuntu 16.04 xenial 
- chef development kit (workstation) 2.4.17-1 
- chef server 12.17.15-1_
- Vagrant 1.9.8
- 5.1.32r120294

*NOTE:* There were relatively large changes from chef 11 to chef 12

*NOTE:* Using other flavors of Linux and MacOS for a host OS should 
should also work,  but your mileage will vary. We'd welcome pull 
requests to improve documentation or usability. 

## chef bootstrap takes what chef.io gives us for chef-client 
Again, this should be fine.  If there are problems many people
will have them.  If you fear change, figure out how to install
the same version of chef client every time you run `chef bootstrap`

## Other virtualbox/vagrant guests on 192.168.56.* and vboxnet0 
If you are using 192.168.56.[1-5] someplace else, you will be sad.

##  We *append* entries guest /etc/hosts There will be duplicates.
Every time the vagrant guests start we append entries to /etc/hosts. 
We do not automatically edit /etc/hosts

If you change IP addresses for existing hosts or add IP addresses 
for new hosts:
1. edit setup/etc_hosts_additions on the Host OS
1. /etc/hosts on the Host OS 
1. do a `vagrant destroy` and `vagrant up` to pass the changes to the 
   guests

Otherwise there will be no problems. The OS uses the first entry in 
/etc/hosts 

## hostname / vagrant names can have no '-' or '_'
Vagrant machine names can't contain '-'. Linux host names can't contain  
'_' , we use the same name for both. If you edit Vagrantfile.yaml and 
edit or add host/vagrant names with '-' or '_' , there will be tears.

## Back up chef-repo/ or change the dir name and edit config
Our code calls  `chef generate repo` to create /home/vagrant/chef-repo/
if it doesn't already exist on the guest host chefworkstation01. This 
directory is virtualbox synced folder on vagrant-chef12/chef-repo , so 
if you make changes, they will be preserved after a `vagrant destroy` 

We check to see if the directory has contents before doing the `chef 
generate repo` and chef seems to respect existing files. However, if 
there are bugs, your changes will be overwritten. 

*NOTE:* Be careful messing with .gitignore as that keeps the git repo 
in chef-repo separate from the one in the parent directory 

## possible ssh issues 
We copy $HOME/.vagrant.d/insecure_private_key on the Host OS to 
/home/vagrant/.ssh/id_rsa on the guest boxes. 

This means:
- ssh between vagrant guests will fail on Host OSes that keep 
  insecure_private_key someplace else. 
- We are extra insecure. insecure_private_key is distributed world wide 

On a different host OS, you could probably find and copy 
`insecure_private_key` to `setup/` just once. 

# SEE ALSO 
      Mastering Chef Provisioning  on https://play.google.com/books/

