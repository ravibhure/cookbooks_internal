# For the final version of this cookbook, this recipe would do something like
# detach the server from the cluster and remove (and possibly add) some tags.

rightscale_marker :begin

#
# Delete some tags
#
tag = node[:glusterfs][:tag][:attached]
log "===> Deleting tag #{tag}=true"
right_link_tag "#{tag}=true" do
  action :remove
end

tag = node[:glusterfs][:tag][:spare]
log "===> Deleting tag #{tag}=true"
right_link_tag "#{tag}=true" do
  action :remove
end

#
# Clear the values of some tags
#
tag = node[:glusterfs][:tag][:volume]
log "===> Setting tag #{tag}=none"
right_link_tag "#{tag}=none"

tag = node[:glusterfs][:tag][:brick]
log "===> Setting tag #{tag}=none"
right_link_tag "#{tag}=none"


rightscale_marker :end
