rightscale_marker :begin

  TAG = node[:glusterfs][:tag][:spare]
  log "===> Removing tag #{TAG}=true"

  right_link_tag "#{TAG}=true" do
    action :remove
  end

rightscale_marker :end
