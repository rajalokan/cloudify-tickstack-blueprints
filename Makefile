bootstrap:
	cfy install openstack.yaml -b tickstack -i server_name=tickstack

update:
	cfy dep update tickstack -p openstack.yaml

cancel_install:
	cfy exec cancel `cfy exec li -d tickstack | grep "started " | cut -d'|' -f2`

uninstall:
	cfy uninstall tickstack -p ignore_failure=true
