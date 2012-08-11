rightscale_marker :begin

TAG = node[:glusterfs][:tag][:attached]

# find all servers with TAG
r = server_collection "glusterfs_attached" do
  tags "#{TAG}=true"
  action :nothing
end
r.run_action(:load)

# grab the uuid of the first one (doesn't matter which one we use)
peer = ""
r = ruby_block "find an attached peer" do
  block do
    node[:server_collection]["glusterfs_attached"].each do |id, tags|
      peer = tags.detect { |u| u =~ /^server:uuid=/ }
      Chef::Log.info "===> Found attached peer: #{peer}"
      break # only need one host
    end
  end
end
r.run_action(:create)

if ! peer.empty?
  log "===> Running remote recipe on #{peer}"
  remote_recipe "Handle our probe request" do
    recipe "glusterfs::server_handle_probe_request"
    attributes :glusterfs => {:server => {:peer => node[:ipaddress]}}
    recipients_tags peer  #server:uuid
  end
else
  log "===> No existing GlusterFS servers found; we must be the first one."
end

# XXX how to check result of remote_recipe?
#     i don't want to set the tag if the remote_recipe above ran AND failed.
#
# we also tag ourselves outside the previous conditional because, what if we're
# the first server in the cluster?  The next server launched will find us and
# request that we add him as a peer.
#
log "===> Tagging myself with '#{TAG}=true'"
right_link_tag "#{TAG}=true"

rightscale_marker :end
