#!/bin/bash -xeu

# Install netdata
echo "Install netdata."
bash <(curl -Ss https://my-netdata.io/kickstart.sh)

# Install pt-query-digest
echo "Install pt-query-digest."
wget https://github.com/percona/percona-toolkit/archive/refs/tags/v3.3.1.tar.gz
tar zxf v3.3.1.tar.gz
sudo mv ./percona-toolkit-3.3.1/bin/pt-query-digest /usr/local/bin/pt-query-digest

echo "pt-query-digest is successfully installed: " && pt-query-digest --version

# Install alp
echo "Install alp."
wget https://github.com/tkuchiki/alp/releases/download/v1.0.7/alp_linux_amd64.zip
unzip -o alp_linux_amd64.zip
sudo mv alp /usr/local/bin/alp
echo "alp is successfully installed: " && alp --version

sudo touch /etc/nginx/conf.d/log_format.conf
sudo chmod 777 /etc/nginx/conf.d/log_format.conf
sudo echo 'log_format ltsv "time:$time_local"
                "\thost:$remote_addr"
                "\tforwardedfor:$http_x_forwarded_for"
                "\treq:$request"
                "\tstatus:$status"
                "\tmethod:$request_method"
                "\turi:$request_uri"
                "\tsize:$body_bytes_sent"
                "\treferer:$http_referer"
                "\tua:$http_user_agent"
                "\treqtime:$request_time"
                "\tcache:$upstream_http_x_cache"
                "\truntime:$upstream_http_x_runtime"
                "\tapptime:$upstream_response_time"
                "\tvhost:$host";
access_log /var/log/nginx/access.log ltsv;' > /etc/nginx/conf.d/log_format.conf