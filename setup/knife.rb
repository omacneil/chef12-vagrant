config_log_level        'warn'
node_name                'admin'
client_key               '/home/vagrant/.chef/admin.pem'
#validation_client_name   'chef-validator'
#validation_key           '/home/vagrant/.chef/acme-org-validator.pem'
chef_server_url          'https://chefserver01/organizations/acme'
syntax_check_cache_path  '/home/vagrant/.chef/syntax_check_cache'
cookbook_path [ '/home/vagrant/chef-repo//cookbooks' ]
