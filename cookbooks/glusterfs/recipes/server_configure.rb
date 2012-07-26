rs_utils_marker :begin

VOL_FILE = "/etc/glusterfs/glusterd.vol"

log "===> Templating #{VOL_FILE}"
template VOL_FILE do
  source  "glusterd.vol.erb"
  #notifies :restart, "service[glusterd]"
end

log "===> Enabling glusterd service"
service "glusterd" do
  action [ :enable, :start ]
  supports :status => true, :restart => true
  ignore_failure true
end

bash "make sure it started" do
  code <<-EOF
    i=0
    while ! pgrep glusterd
    do
      /etc/init.d/glusterd start
      i=`expr $i + 1`
      [ $i -eq 10 ] && break
    done
  EOF
end

rs_utils_marker :end
