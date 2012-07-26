rs_utils_marker :begin

TAG_SPARE  = node[:glusterfs][:tag][:spare]
VOL_NAME   = node[:glusterfs][:volume_name]
EXPORT_DIR = node[:glusterfs][:server][:storage_path]
REPL_COUNT = node[:glusterfs][:server][:replica_count]

# find all servers marked as 'spares' (not in use)
server_collection "glusterfs" do
  tags "#{TAG_SPARE}=true"
end

ruby_block "Add peers and create volume" do
  block do
    hosts = []

    # grab IPs of the spares
    node[:server_collection]["glusterfs"].each do |id, tags|
      ip_tag = tags.detect { |i| i =~ /^server:private_ip_0=/ }
      ip = ip_tag.gsub(/^.*=/, '')
      next if ip == node[:ipaddress] # skip ourself

      Chef::Log.info "===> Found server #{ip}"
      hosts << ip
    end

    # XXX assumes replica_count=2
    if hosts.empty?
      raise "!!!> Didn't find any servers with tag #{TAG_SPARE}=true"
    end

    # Probe each IP to attach as peer
    hosts.each do |ip|
      Chef::Log.info "===> Gluster peer probe #{ip}"
      system "gluster peer probe #{ip}"
      raise "Couldn't add #{ip} to cluster" unless $?.success?
    end

    # Create a new volume from bricks
    Chef::Log.info "===> Creating volume #{VOL_NAME}"

    cmd = "gluster volume create #{VOL_NAME}" +
          " replica #{REPL_COUNT} transport tcp"

    [node[:ipaddress], hosts].flatten.each do |ip|
      cmd += " #{ip}:#{EXPORT_DIR}"
    end

    system cmd
    raise "!!!> Volume creation failed" unless $?.success?

    # Set some options on the volume
    Chef::Log.info "===> Configuring volume."
    SET_OPT = "gluster volume set #{VOL_NAME}"

    # FIXME should be glusterfs/server/volume_options input
    system "#{SET_OPT} auth.allow 172.*,10.*"
    system "#{SET_OPT} nfs.disable on"
    system "#{SET_OPT} network.frame-timeout 60"

    # Finally start the volume
    Chef::Log.info "===> Starting volume."
    system "gluster volume start #{VOL_NAME}"
    raise "!!!> Volume didn't start" unless $?.success?

  end #block do
end #ruby_block do

# Remove TAG_SPARE from remote host
log "===> Running remote recipes to remove tags"
remote_recipe "delete_tag" do
  recipe "glusterfs::server_handle_tag_delete"
  recipients_tags "#{TAG_SPARE}=true"
end
  
rs_utils_marker :end
