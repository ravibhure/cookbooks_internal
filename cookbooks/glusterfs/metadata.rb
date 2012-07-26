maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Apache 2.0"
description      "GlusterFS recipes" 
version          "0.0.1"

depends "rs_utils"
depends "aria2"

recipe "glusterfs::default", "Sets attributes but does nothing"
recipe "glusterfs::install", "Download and installs glusterfs "
recipe "glusterfs::server_configure", "Configures glusterd"
recipe "glusterfs::server_set_tags", "Add 'glusterfs:*' tags so other servers can find us"
recipe "glusterfs::server_request_probe", "Find an existing/attached GlusterFS server and request to be attached to the cluster"
recipe "glusterfs::server_handle_probe_request", "Remote recipe intended to be called by glusterfs::server_request_probe"
recipe "glusterfs::server_create_cluster", "Finds tagged servers and initializes the GlusterFS volume"
recipe "glusterfs::server_handle_tag_delete", "Remote recipe intended to be called by glusterfs::server_create_cluster"
recipe "glusterfs::server_decommission", "Remove some tags so new clients/peers won't find us"
recipe "glusterfs::client_mount_volume", "Runs mount(8) with `-t glusterfs' option to mount glusterfs"

attribute "glusterfs/package_url",
    :display_name => "Download URL",
    :description  => "The URL of the GlusterFS deb",
    :required     => "recommended",
    :default      => "https://rs-samsung-assets.s3.amazonaws.com/glusterfs%2Fglusterfs_3.2.6-1_amd64.deb",
    :recipes      => [ "glusterfs::install"]

attribute "glusterfs/volume_name",
    :display_name => "Volume Name",
    :description  => "The name of the exported volume on the GlusterFS server",
    :required     => "required",
    :recipes      => [ "glusterfs::server_set_tags",
                       "glusterfs::server_create_cluster",
                       "glusterfs::client_mount_volume" ]

attribute "glusterfs/server/storage_path",
    :display_name => "Storage Path",
    :description  => "The directory path to be used as a brick and added to the GlusterFS volume",
    :required     => "required",
    :recipes      => [ "glusterfs::server_set_tags",
                       "glusterfs::server_create_cluster"]

attribute "glusterfs/server/replica_count",
    :display_name => "Replica Count",
    :description  => "The directory path to be added to the volume as a brick",
    :required     => "optional",
    :default      => "2",
    :recipes      => [ "glusterfs::server_create_cluster" ]

#attribute "glusterfs/server/peer",
#    :display_name => "Peer Name",
#    :description  => "The hostname or IP of the peer to attach",
#    :required     => "optional",
#    :recipes      => [ "glusterfs::server_handle_probe_request"]

attribute "glusterfs/client/mount_point",
    :display_name => "Mount point",
    :description => "The directory of where to mount the glusterfs (e.g., /mnt/storage).",
    :type => "string",
    :required => "recommended",
    :default => "/home/chaton/gluster",
    :recipes => [ "glusterfs::client_mount_volume"]

attribute "glusterfs/client/mount_options",
    :display_name => "Mount Options",
    :description  => "Extra options to be passed to the mount command",
    :required     => "optional",
    :recipes      => [ "glusterfs::client_mount_volume"]

