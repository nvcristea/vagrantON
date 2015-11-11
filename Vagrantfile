# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'
require './core/config.rb'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
puts "VagrantON: #{CONF['stacks'][STACK_ID]}"
puts "#{STACK['network']['private_ip']}"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Setup BOX
  config.vm.box = "#{STACK['box']['name']}"
  config.vm.box_url = "#{STACK['box']['url']}"
  config.vm.hostname = "#{STACK['hostname']}"
  config.ssh.forward_agent = "#{CONF['forward_agent']}"


  # Provider
  config.vm.provider :virtualbox do |vb|
    vb.name = "#{STACK['name']}"
    vb.gui = false
    vb.customize ["modifyvm", :id, "--memory", "#{CONF['memory']}"]
    vb.customize ["modifyvm", :id, "--cpus", "#{CONF['cpus']}"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.customize ["modifyvm", :id, "--vram", "#{CONF['video_memory']}"]
    if "#{CONF['ssd']}" == "true"
      vb.customize ['storageattach', :id, '--storagectl', 'IDE Controller',
                      '--port', '0', '--device', '0', '--nonrotational', 'on']
    end
  end


  # Setup Port Forwarding
  if "#{CONF['forward_port']}" == "true"
    CONF['forwarded_port'].each do |fp_guest, fp_host|
       config.vm.network :forwarded_port, guest: "#{fp_guest}", host: "#{fp_host}"
    end
  end


  # Folder sharing
  config.vm.synced_folder "./stacks/#{CONF['stacks'][STACK_ID]}/puppet_ssl", "/vagrant/puppet_ssl"
  CONF['share'].each do |share|
    share_group = 'vagrant'
    share_group = 'apache' if share['target'] =~ /www\/html/ and !Vagrant::Util::Platform.windows?
    config.vm.synced_folder share['source'], share['target'], create: true, owner: 'vagrant', group: share_group
  end


  # Provision
  config.vm.provision :shell, :path => "core/puppet.sh", :args => ["#{STACK['puppet']['ip']}", "#{STACK['puppet']['host']}"]

  config.vm.provision "puppet_server" do |puppet|
    puppet.puppet_server = "#{STACK['puppet']['host']}"
    puppet.puppet_node = "#{STACK['puppet']['node']}"
    puppet.options = "#{STACK['puppet']['options']}"
  end


  # Additional
  ## Cachier
  if Vagrant.has_plugin?('vagrant-cachier')
    # Configure cached packages to be shared between instances of the same base box.
    # More info on the "Usage" link above
    config.cache.scope = :box
    if Gem::Requirement.new('>= 0.7.1').satisfied_by?(
      Gem::Version.new(VagrantPlugins::Cachier::VERSION))
      config.cache.enable :generic, {
        'wget' => { cache_dir: '/var/cache/wget' },
        'git' => { cache_dir: '/var/cache/git' },
        'oracle12c' => { cache_dir: '/var/cache/oracle12c' }
      }
    else
      config.cache.enable :generic, { name: 'wget', cache_dir: '/var/cache/wget' }
    end
  end

  ## SSH Platform Windows
  if Vagrant::Util::Platform.windows?
    # You MUST have a ~/.ssh/id_rsa SSH key to copy to VM
    # (ensures we are not just copying all your local SSH keys to a VM)
    if File.exists?(File.join(Dir.home, ".ssh", "id_rsa"))
      # Read local machine's SSH Key (~/.ssh/id_rsa)
      ssh_key = File.read(File.join(Dir.home, ".ssh", "id_rsa"))
      # Copy it to VM as the /root/.ssh/id_rsa key
      config.vm.provision :shell do |shell|
         shell.inline = "echo 'Windows-specific: Copying local SSH Key to VM for provisioning...' && mkdir -p $1 && echo '#{ssh_key}' > $2 && chmod 600 $2 && touch $3 && ssh-keyscan -H $4 >> $3 && chmod 600 $3"
         shell.args = %q{/root/.ssh /root/.ssh/id_rsa /root/.ssh/known_hosts "github.com"}
      end
    else
      # Else, throw a Vagrant Error. Cannot successfully startup on Windows without a SSH Key!
      raise Vagrant::Errors::VagrantError, "ERROR: SSH Key not found at ~/.ssh/id_rsa"
    end
  end

  ## Defining Multiple Machines
  config.vm.define "#{CONF['stacks'][STACK_ID]}" do |web|

    web.vm.hostname="#{STACK['hostname']}"
    web.vm.network :private_network, ip: "#{STACK['network']['private_ip']}"
    if File.exists?('provision.sh')
      web.vm.provision :shell, :path => "provision.sh", :args => ["#{CONF['stacks'][STACK_ID]}"]
    end

    end

end