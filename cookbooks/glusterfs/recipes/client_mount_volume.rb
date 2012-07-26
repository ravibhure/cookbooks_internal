#Cookbook Name:: glusterfs
#
# Copyright RightScale, Inc. All rights reserved. All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

VOL_NAME    = node[:glusterfs][:volume_name]
MOUNT_POINT = node[:glusterfs][:client][:mount_point]
MOUNT_OPTS  = node[:glusterfs][:client][:mount_options]
TAG_VOLUME  = node[:glusterfs][:tag][:volume]

# find all servers with a glusterfs_server:volume= tag
r = server_collection "glusterfs" do
  tags "#{TAG_VOLUME}=#{VOL_NAME}"
  action :nothing
end
r.run_action(:load)

glusterfs_ip=""
r = ruby_block "Find Server IP" do
  block do
    # grab IP of the first server (doesn't matter which one we use)
    node[:server_collection]["glusterfs"].each do |id, tags|
      ip_tag = tags.detect { |i| i =~ /^server:private_ip_0=/ }
      glusterfs_ip = ip_tag.gsub(/^.*=/, '')
      break
    end
  end
  action :nothing
end
r.run_action(:create)

if glusterfs_ip.empty?
    raise "!!!> Didn't find any servers with tag #{TAG_VOLUME}=#{VOL_NAME}"
else
    log "===> Found GlusterFS server at #{glusterfs_ip}"
end

# load fuse module
bash "modprobe fuse" do
  code <<-EOF
    if modinfo fuse &>/dev/null; then
      if grep -q fuse /proc/modules; then
        echo "Fuse already loaded, skipping..."
      else
        echo "Fuse available but not loaded, running modprobe"
        modprobe fuse
      fi
    fi
  EOF
  #only_if "modinfo fuse &>/dev/null && ! grep -q fuse /proc/modules"
end

# create mount point
log "===> Creating mount point #{MOUNT_POINT}"
directory MOUNT_POINT do
  recursive true
end

# mount remote filesystem
log "===> Mounting GlusterFS volume"
bash "mount_glusterfs" do
  user "root"
  code <<-EOF
    opts=
    [ -n "#{MOUNT_OPTS}" ] && opts="-o #{MOUNT_OPTS}"
    mount -t glusterfs $opts #{glusterfs_ip}:/#{VOL_NAME} #{MOUNT_POINT} 
  EOF
  not_if "/bin/grep -qw '#{MOUNT_POINT}' /proc/mounts"
end

rs_utils_marker :end

