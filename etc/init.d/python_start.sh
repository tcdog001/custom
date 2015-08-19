#!/bin/bash

nofunc() {
package="/mnt/hd/bus/"
install_path="/mnt/hd/python"

if [ ! -d ${package} ]; then
                echo "Error:there is no ${package}"
                exit 1
fi

#########################

cp "${package}"/python2.7  /usr/bin
cp "${package}"/python2.7-config  /usr/bin
cd /usr/bin
chmod 777 python2.7
chmod 777 python2.7-config
ln -s python2.7-config python2-config 
ln -s python2-config python-config 
ln -s python2.7 python2 
ln -s python2 python

#########################

mkdir ${install_path} 
mkdir ${install_path}/lib
tar zxvf "${package}"/python2.7.tar.gz  -C "${install_path}/lib" 

#########################

tar zxvf  ${package}/setuptools-0.6c11.tar.gz  -C "${install_path}"
cd "${install_path}"/setuptools-0.6c11  
python setup.py install

if [ ! -f /usr/bin/django-admin.py ]; then
	ln -s "${install_path}"/bin/django-admin.py /usr/bin/django-admin.py
fi

#########################

cp ${package}/nginx.conf /usr/local/nginx/conf/nginx.conf 
##是否需要reload nginx ??
cp -rf ${package}/kumihua-server /mnt/hd
cp -rf ${package}/portal_server /mnt/hd
cp ${package}/usr/bin/* /usr/bin/
cp ${package}/usr/lib/* /usr/lib/

#########################

}

if [ ! -f /usr/bin/django-admin.py ]; then
	ln -s /mnt/hd/python/bin/django-admin.py /usr/bin/django-admin.py
fi

if [ -d /mnt/hd/kumihua-server  ]; then
	cd /mnt/hd/kumihua-server 
	python manage.py runserver 0.0.0.0:8001 &    
fi
if [ -d /mnt/hd/portal_server  ]; then
	cd /mnt/hd/portal_server
	python manage.py runserver &
fi

if [ ! -d /tmp/um ]; then
	mkdir /tmp/um
fi

