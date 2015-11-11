#!/usr/bin/ruby
require 'yaml'

conf_file = Dir.pwd + '/config.yml'
core_conf_file = Dir.pwd + '/core/config.yml'

if File.file?(core_conf_file) then
    YMLCoreConf = YAML.load_file(core_conf_file)
    CONF = YMLCoreConf['DEFAULT_STACK']
    STACK = YMLCoreConf['STACK']
end

if ARGV[1]
    STACK_ID = CONF['stacks'].index(ARGV[1])
elsif ENV['ACTIVE_STACK']
    STACK_ID = CONF['stacks'].index(ENV['ACTIVE_STACK'])
end

if File.file?(conf_file) then
    YMLConf = YAML.load_file(conf_file)
    STACK_ID = YMLConf['ACTIVE_STACK'] if !YMLConf['ACTIVE_STACK'].nil? unless defined? STACK_ID
    if YMLConf['STACKS'][CONF['stacks'][STACK_ID]]
        YMLConf['STACKS'][CONF['stacks'][STACK_ID]].each do |key, item|
            CONF[key.downcase] = item
        end
    end
end

STACK_ID = CONF['selected'] unless defined? STACK_ID

STACK['name'] << "_" + CONF['stacks'][STACK_ID]
STACK['network']['private_ip'] << "#{STACK_ID}"
STACK['hostname'] = "#{STACK['hostname']['prefix'][STACK_ID]}#{STACK['hostname']['domain']}"
STACK['puppet']['node'] = STACK['hostname']
STACK['puppet']['options'] = "#{STACK['puppet']['options']} #{CONF['puppet']['options']}"

