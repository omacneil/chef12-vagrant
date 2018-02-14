Please don't remove this file. 

The parent git ( https://github.com/omacneil/chef12-vagrant )
repo needs it. 

This file exists to tell git in the parent directory to 
exclude contents of this directory (chef-repo), 
but to include an empty directory so that the 
provisioning process can do a 

  chef generate repo $V_HOME/chef-repo

..so you have the reccomended starting place for chef

This directory can (and probably should) 
be a different git repository that you 
use to keep track of your chef test/play/learning

The goal of the parent project is quickly get a 
basic chef setup created, using it is outside of  
