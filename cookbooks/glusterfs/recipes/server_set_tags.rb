rs_utils_marker :begin

TAG_VOLUME = node[:glusterfs][:tag][:volume]
TAG_BRICK  = node[:glusterfs][:tag][:brick]
TAG_SPARE  = node[:glusterfs][:tag][:spare]

INPUT_VOLUME = node[:glusterfs][:volume_name]
INPUT_BRICK  = node[:glusterfs][:server][:storage_path]

log "===> Tagging myself with #{TAG_VOLUME}=#{INPUT_VOLUME}"
right_link_tag "#{TAG_VOLUME}=#{INPUT_VOLUME}"

log "===> Tagging myself with #{TAG_BRICK}=#{INPUT_BRICK}"
right_link_tag "#{TAG_BRICK}=#{INPUT_BRICK}"

log "===> Tagging myself with #{TAG_SPARE}=true"
right_link_tag "#{TAG_SPARE}=true"

rs_utils_marker :end
