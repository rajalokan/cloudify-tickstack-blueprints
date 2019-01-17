bootstrap:
	cfy install openstack.yaml -b tickstack -i server_name=tickstack

update:
	cfy dep update tickstack -p openstack.yaml

uninstall:
	cfy uninstall tickstack -p ignore_failure=true
