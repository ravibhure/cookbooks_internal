#
# Cookbook Name:: Hadoop
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module Hadoop
    module Helper
            
      # get a list of hosts from the server tags
      def get_hosts(type) 
        hadoop_servers = Set.new
        
        r=  server_collection "hosts" do
          tags "hadoop:node_type=#{type}"
          action :nothing
        end
        r.run_action(:load)

        node[:server_collection]['hosts'].to_hash.values.each do |tags|
          ip = RightScale::Utils::Helper.get_tag_value('server:private_ip_0', tags)
          hadoop_servers.add?(ip)
        end    
        hadoop_servers
      end
      
      # Add public key for root to ssh to itself as needed by hadoop.
      #
      # @param public_ssh_key [string] public key to add
      #
      # @raises [RuntimeError] if ssh key string is empty
      def add_public_key(public_ssh_key)
        Chef::Log.info("  Updating authorized_keys ")
       
        directory "/root/.ssh" do
          recursive true
        end
        if "#{public_ssh_key}" != ""
         
          # Writing key to file
          system("echo '#{public_ssh_key}' >> /root/.ssh/authorized_keys")
          # Setting permissions
          system("chmod 0600 /root/.ssh/authorized_keys")
        end

      end
    
    end
  end
end