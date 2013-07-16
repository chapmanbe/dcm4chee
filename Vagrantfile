# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  #config.vm.network :forwarded_port, guest: 8080, host: 8080
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ".."
    #chef.roles_path = "../my-recipes/roles"
    #chef.data_bags_path = "../my-recipes/data_bags"
    chef.add_recipe "dcm4chee"
    #chef.add_role "web"
    #chef.json = { :mysql_password => "foo" }
  end
end
