bootstrap:
	cfy install openstack.yaml -b tickstack -i server_name=tickstack

uninstall:
	cfy uninstall tickstack 
