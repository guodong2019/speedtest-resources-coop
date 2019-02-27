#!/bin/sh

# install openresty
apt-get install libpcre3 libpcre3-dev openssl libssl-dev libreadline-dev perl make build-essential libncurses5-dev curl
wget https://openresty.org/download/openresty-1.13.6.1.tar.gz
tar -xzf openresty-1.13.6.1.tar.gz
cd openresty-1.13.6.1
./configure --with-luajit --with-http_stub_status_module --with-http_iconv_module && make -j2 && make install
echo 'export PATH=/usr/local/openresty/bin:/usr/local/openresty/nginx/sbin:$PATH' >> ~/.bashrc
# source ~/.bashrc

# copy nginx conf
cp resources/nginx.conf /usr/local/openresty/nginx/conf
# upload lua
upload_file_path="/usr/local/openresty/nginx/conf/lua/"
mkdir -p ${upload_file_path}
cp resources/savefile.lua ${upload_file_path}"/"

downloadroot="/usr/local/openresty/nginx/html/speedtest/"
# generate random files for downloading
for v in 30 50 100
do
    dd if=/dev/zero of=${downloadroot}${v}mb.dat  bs=${v}M  count=1
done
# copy test file for downloading
cp resources/test.txt ${downloadroot}

# start nginx
# dir for save upload files
mkdir -p /tmp/uploads/
/usr/local/openresty/nginx/sbin/nginx

# report server status

# report stats
