rs_utils_marker :begin

  peer_name = node[:glusterfs][:server][:peer]
  log "===> Going to probe peer #{peer_name}"

  execute "gluster peer probe #{peer_name}"

rs_utils_marker :end
