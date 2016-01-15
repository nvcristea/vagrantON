#!/usr/bin/ruby
require 'yaml'

CONF_PATH = Dir.pwd + '/config/'

Dir.glob(CONF_PATH + "*.yml") do |yml_conf_file|
    if File.file?(yml_conf_file) then
        $YMLConf = YAML.load_file(yml_conf_file)
        if $YMLConf['DEFAULT_STACK']
            CONF = $YMLConf['STACK'].merge($YMLConf['DEFAULT_STACK'])
            if ARGV[1] && CONF['stacks'].include?(ARGV[1])
                STACK_ID = CONF['stacks'].index(ARGV[1])
            elsif ENV['ACTIVE_STACK']
                STACK_ID = CONF['stacks'].index(ENV['ACTIVE_STACK'])
            end
        elsif $YMLConf['STACKS']
            STACK_ID = CONF['stacks'].index($YMLConf['ACTIVE_STACK']) if !$YMLConf['ACTIVE_STACK'].nil? unless defined? STACK_ID
            if $YMLConf['STACKS'][CONF['stacks'][STACK_ID]]
                $YMLConf['STACKS'][CONF['stacks'][STACK_ID]].each do |key, item|
                    CONF[key.downcase] = item
                end
            end
        end
        if $YMLConf['CONF_FILE']
            CONF['CONF_FILE'] = $YMLConf['CONF_FILE']
        end
    end
end

if CONF['CONF_FILE'] and File.file?(CONF_PATH + CONF['CONF_FILE']) then
    $YMLConf = YAML.load_file(CONF_PATH + CONF['CONF_FILE'])
    if $YMLConf['STACKS']
        STACK_ID = CONF['stacks'].index($YMLConf['ACTIVE_STACK']) if !$YMLConf['ACTIVE_STACK'].nil? unless defined? STACK_ID
        if $YMLConf['STACKS'][CONF['stacks'][STACK_ID]]
            $YMLConf['STACKS'][CONF['stacks'][STACK_ID]].each do |key, item|
                CONF[key.downcase] = item
            end
        end
    end
end

STACK_ID = CONF['active'] unless defined? STACK_ID

CONF['name'] << "_" + CONF['stacks'][STACK_ID]
CONF['network']['private_ip'] << "#{STACK_ID}"
CONF['hostname'] = "#{CONF['hostname']['prefix'][STACK_ID]}#{CONF['hostname']['domain']}"
CONF['puppet']['node'] = CONF['hostname']

#puts YAML::dump(CONF)
