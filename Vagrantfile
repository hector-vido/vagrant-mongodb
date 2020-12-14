# -*- mode: ruby -*-
# vi: set ft=ruby :

vms = {
  'db1' => {'memory' => '4096', 'cpus' => 2, 'ip' => '10', 'box' => 'debian/buster64', 'provision' => 'mongodb.sh'},
  'db2' => {'memory' => '4096', 'cpus' => 2, 'ip' => '20', 'box' => 'debian/buster64', 'provision' => 'mongodb.sh'},
  'db3' => {'memory' => '4096', 'cpus' => 2, 'ip' => '30', 'box' => 'debian/buster64', 'provision' => 'mongodb.sh'},
}

Vagrant.configure('2') do |config|

  config.vm.box_check_update = false

  vms.each do |name, conf|
    config.vm.define "#{name}" do |my|
      my.vm.box = conf['box']
      my.vm.hostname = "#{name}.example.com"
      my.vm.network 'private_network', ip: "172.27.11.#{conf['ip']}"
      my.vm.provision 'shell', path: "provision/#{conf['provision']}"
      my.vm.provider 'virtualbox' do |vb|
        vb.memory = conf['memory']
        vb.cpus = conf['cpus']
      end
      my.vm.provider 'libvirt' do |lv|
        lv.memory = conf['memory']
        lv.cpus = conf['cpus']
        lv.cputopology :sockets => 1, :cores => conf['cpus'], :threads => '1'
      end
    end
  end

end
