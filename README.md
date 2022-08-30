# EasyManager

> Simple ruby library to manage cloud servers

**Available provider :**
* Scaleway

**Scaleway available images:**
* debian-buster
* ubuntu-jammy

**Scaleway available instances:**
* DEV1-S
* DEV1-M
* DEV1-L
* DEV1-XL

## Installation

In your Gemfile
```ruby
gem 'easy_manager', '~> 0.9.1'
```

Or
```bash
gem install easy_manager
```

## Usage example

```ruby
require 'easy_manager'

options = {
  zone: 'fr-par-1',
  project: 'YOUR-PROJECT-ID',
  secret_token: 'YOUR-SECRET-TOKEN'
}

manager = EasyManager::Scaleway.new(options)
ssh = EasyManager::SSH.new

# Displays all instances
servers = manager.list
puts servers

# Create a new instance
# It is possible to pass the following arguments :
#  { srv_type: 'DEV1-S', image: 'ubuntu-jammy', name_pattern: 'scw-easymanager-__RANDOM__', cloud_init: false }
srv = manager.create({ cloud_init: "#{__dir__}/cloud-init.yml" })

# Sleep unitil the server is ready, the default timeout value is 300
timeout = 60 
ready = wait_until_ready!(timeout)
return unless ready

# It is also possible to check independently if the server is ready
manager.srv_ready?(srv, ssh)

# Executes multiple commands and stores the results
cmds = %w[id hostname]
cmd_results = EasyManager::SSH.cmd_exec(ssh, srv, cmds)

cmd_results.each do |cmd, result|
  p "Executed cmd : '#{cmd}' and get : '#{result}'"
  # > "Executed cmd : 'id' and get : 'uid=0(root) gid=0(root) groups=0(root)'"
  # > "Executed cmd : 'hostname' and get : 'scw-easymanager-uklyyuqi'"
end

# Transfer a file and a folder in recursive mode on the server
files = {
  '/tmp/file1.txt' => {
    remote: '/tmp'
  },
  '/tmp/folder' => {
    remote: '/tmp/another',
    recursive: true
  }
}
EasyManager::SSH.scp(ssh, srv, files)

# Delete the server
manager.delete(srv)
manager.delete_by_id('xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx')
```