#Cookbook Name:: glusterclient
#
# Copyright RightScale, Inc. All rights reserved. All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

require 'uri'
include_recipe "aria2"

URL = node[:glusterfs][:package_url]
PKG = URL.gsub(/.*\//, '') # strip off path

log "===> Downloading #{URL}"
bash "download_gluster_pkg" do
  cwd '/tmp'
  code <<-EOF
    aria2c #{URL}
  EOF
end

log "===> Installing nfs-common"
package "nfs-common"

log "===> Installing glusterfs package"
dpkg_package "glusterfs" do
  source "/tmp/#{URI.unescape(PKG)}"
  action :install
end

rs_utils_marker :end

