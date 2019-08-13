---
title: "Running OpenStack in Vagrant via RDO"
date: 2019-08-13T15:22:14-04:00
draft: true
---

This is how to run a single-node OpenStack cluster using the [RDO project](https://rdoproject.org)'s
[packstack](https://rdoproject.org/install/packstack/) installation utility.
I packed everything into a `Vagrantfile` so it can easily be redeployed.
Huge credit goes to [codingpackets.com](https://codingpackets.com) for
providing the `answers.cfg` and network requirements. I don't honestly know
yet why the network requirements are such; I just know this works.

In a new directory, create a `Vagrantfile` containing:

```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "rdo" do |node|
    node.vm.hostname = "rdo.localdomain"
    node.vm.box = "centos/7"
    node.vm.synced_folder ".", "/vagrant", disabled: true
    node.ssh.insert_key = false

    node.vm.provider :libvirt do |domain|
      domain.memory = 2048
      domain.cpus = 2
    end

    node.vm.network :private_network, :ip => "10.254.254.100",
      :libvirt__network_name => "os-data",
      :libvirt__forward_mode => "none",
      :libvirt__netmask => "255.255.255.0",
      :dhcp_enabled => false

    node.vm.network :private_network, :ip => "169.254.169.254",
      :libvirt__network_name => "os-mgmt",
      :libvirt__forward_mode => "none",
      :libvirt__netmask => "255.255.255.255",
      :dhcp_enabled => false

    node.vm.provision :file, source: "./answers.cfg", destination: "/home/vagrant/answers.cfg"

    node.vm.provision :shell, inline: <<-SHELL
      systemctl disable --now firewalld
      systemctl disable --now NetworkManager
      systemctl enable  --now network
      
      yum -y install centos-release-openstack-stein
      yum -y update
      yum -y install openstack-packstack

      packstack --answer-file=/home/vagrant/answers.cfg
    SHELL
  end
end
```

Next, create `answers.cfg` in the same directory as your `Vagrantfile` with
contents:

```ini
# answers.cfg
[general]

# Generic config options
CONFIG_UNSUPPORTED=n
CONFIG_DEBUG_MODE=n
CONFIG_PROVISION_DEMO=n

# Default password to be used everywhere
CONFIG_DEFAULT_PASSWORD=openstack

#Install the following services
CONFIG_MARIADB_INSTALL=y
CONFIG_GLANCE_INSTALL=y
CONFIG_NOVA_INSTALL=y
CONFIG_NEUTRON_INSTALL=y
CONFIG_HORIZON_INSTALL=y
CONFIG_CLIENT_INSTALL=y

# Configure networking
EXCLUDE_SERVERS=
CONFIG_NTP_SERVERS=
CONFIG_CONTROLLER_HOST=10.254.254.100
CONFIG_COMPUTE_HOSTS=10.254.254.100
CONFIG_NETWORK_HOSTS=10.254.254.100
CONFIG_MARIADB_HOST=10.254.254.100
CONFIG_AMQP_HOST=10.254.254.100
CONFIG_STORAGE_HOST=10.254.254.100
CONFIG_SAHARA_HOST=10.254.254.100
CONFIG_KEYSTONE_LDAP_URL=ldap://10.254.254.100
CONFIG_MONGODB_HOST=10.254.254.100
CONFIG_REDIS_HOST=10.254.254.100

# Configure Neutron
CONFIG_NEUTRON_L3_EXT_BRIDGE=provider
CONFIG_NEUTRON_ML2_MECHANISM_DRIVERS=openvswitch
CONFIG_NEUTRON_ML2_VLAN_RANGES=
CONFIG_NEUTRON_L2_AGENT=openvswitch
CONFIG_NEUTRON_ML2_TYPE_DRIVERS=local,flat
CONFIG_NEUTRON_ML2_FLAT_NETWORKS=*
CONFIG_NEUTRON_ML2_TENANT_NETWORK_TYPES=local
CONFIG_NEUTRON_OVS_BRIDGE_MAPPINGS=physnet1:br-ex
CONFIG_NEUTRON_OVS_BRIDGE_IFACES=br-ex:eth2

#Do not install the following services
CONFIG_CINDER_INSTALL=n
CONFIG_MANILA_INSTALL=n
CONFIG_SWIFT_INSTALL=n
CONFIG_CEILOMETER_INSTALL=n
CONFIG_HEAT_INSTALL=n
CONFIG_SAHARA_INSTALL=n
CONFIG_TROVE_INSTALL=n
CONFIG_IRONIC_INSTALL=n
CONFIG_NAGIOS_INSTALL=n
CONFIG_VMWARE_BACKEND=n
```

I found that the `vagrant-libvirt` provider that shipped with my distribution
(Fedora) caused some problems with creating libvirt networks. The solution
was to install the `vagrant-libvirt` plugin directly with `vagrant`:

```bash
$ vagrant plugin install vagrant-libvirt
```

Next, run `vagrant up` and wait!