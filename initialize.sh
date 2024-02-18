#!/bin/bash -ue

# epel repository 追加
dnf -y install epel-release

# crb repository 有効化
dnf config-manager --enable

# OS 最新化
dnf -y upgarade

# 追加インストール
# certbot  ： SSH 証明書
# nginx    ： HTTP SERVER
# postfix  ： MAIL SERVER
# dovecot  ： MAIL SERVER
# opendkim ： MAIL SERVER
dnf -y install certbot nginx postfix dovecot opendkim vim

# certbot certonly 
certbot certonly --manual --server https://acme-v02.api.letsencrypt.org/directory \
  --preferred-challenges dns  -d *.$DOMAIN -d $DOMAIN -m $MAIL --agree-tos

##############
# nginx 設定 #
##############
sed -i -e "38,54s/^/#/g" -e "s/##/#/g" /etc/nginx/nginx.conf

# 40x/50x 設定
cat << __ERROR_PAGE__ > /etc/nginx/default.d/error.conf
error_page 403 404 410 /404.html;
    location = /40x.html {
}

error_page 500 502 503 504 /50x.html;
    location = /50x.html {
}
__ERROR_PAGE__

cat << __SITE_CONF__ > /etc/nginx/conf.d/default.conf
server {
    listen       80;
    listen       [::]:80;
    server_name  _;
    root         /usr/share/nginx/html;

    # Load configuration files for the default server block.
    include /etc/nginx/default.d/*.conf;
}

# Settings for a TLS enabled server.

server {
    listen       443 ssl http2;
    listen       [::]:443 ssl http2;
    server_name  _;
    root         /usr/share/nginx/html;

    ssl_certificate      "/etc/letsencrypt/live/$DOMAIN/fullchain.pem";
    ssl_certificate_key  "/etc/letsencrypt/live/$DOMAIN/privkey.pem";
    ssl_session_cache    shared:SSL:1m;
    ssl_session_timeout  10m;
    ssl_ciphers          PROFILE=SYSTEM;
    ssl_prefer_server_ciphers on;

    # Load configuration files for the default server block.
    include /etc/nginx/default.d/*.conf;
}
__SITE_CONF__

# nginx 起動設定
nginx -t
systemctl enable nginx
systemctl start  nginx

################
# POSTFIX 設定 #
################
cp -av --backup /etc/postfix/main.cf   /etc/postfix/main.cf.org
cp -av --backup /etc/postfix/master.cf /etc/postfix/master.cf.org

sed -i \
    -e "/# ADD CONFIG /,/^$/d"           \
    -e "/^myhostname/           s/^/#/g" \
    -e "/^mydomain/             s/^/#/g" \
    -e "/^mydestination/        s/^/#/g" \
    -e "/^myorigin/             s/^/#/g" \
    -e "/^mynetworks/           s/^/#/g" \
    -e "/^home_mailbox/         s/^/#/g" \
    -e "/^inet_interfaces/      s/^/#/g" \
    -e "/^smtpd_banner/         s/^/#/g" \
    -e "/^syslog_facility/      s/^/#/g" \
    -e "/^disable_vrfy_command/ s/^/#/g" \
    -e "/^smtpd_tls_cert_file/  s/^/#/g" \
    -e "/^smtpd_tls_key_file/  s/^/#/g" \
  /etc/postfix/main.cf

cat << __POSTFIX_MAIN__ >> /etc/postfix/main.cf

# ADD CONFIG 
myhostname = $MX.$DOMAIN
mydomain   = $MX.$DOMAIN
myorigin   = \$myhostname
mydestination = \$myhostname, localhost, \$mydomain
inet_interfaces = \$myhostname, localhost
mynetworks = 127.0.0.0/8
home_mailbox = .mail
smtpd_banner = \$myhostname ESMTP
message_size_limit = 10485760
mailbox_size_limit = 1073741824
syslog_facility = mail
disable_vrfy_command = yes
smtpd_sasl_auth_enable = yes
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
broken_sasl_auth_clients = yes
smtpd_recipient_restrictions = 
    permit_mynetworks 
    permit_sasl_authenticated 
    reject_unauth_destination
smtpd_tls_cert_file = /etc/letsencrypt/live/$DOMAIN/fullchain.pem
smtpd_tls_key_file = /etc/letsencrypt/live/$DOMAIN/privkey.pem
smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_scache
smtpd_tls_session_cache_timeout = 3600s
smtpd_tls_received_header = yes
smtpd_tls_loglevel = 1

__POSTFIX_MAIN__

sed -i \
    -e "/^#submission/ s/^#//g"  \
    -e "/^#smtps/      s/^#//g"  \
    -e "31,32          s/^#/ /g" \
    -e "38             s/^#/ /g" \
  /etc/postfix/master.cf

# 検証
postfix check
systemctl enable postfix
systemctl start  postfix

################
# DOVECOT 設定 #
################
cp -av --backup /etc/dovecot/conf.d/10-master.conf /etc/dovecot/conf.d/10-master.conf.org
cp -av --backup /etc/dovecot/conf.d/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf.org

sed -i -E                                \
  -e "19  s/#port.*/port = 0/"           \
  -e "22  s/#port.*/port = 993/"         \
  -e "23  s/#ssl.*/ssl = yes/"           \
  -e "40  s/#port.*/port = 0/"           \
  -e "43  s/#port.*/port = 995/"         \
  -e "44  s/#ssl.*/ssl = yes/"           \
  -e "50  s/#port.*/port = 587/"         \
  -e "101 s/#mode.*/mode = 0666/"        \
  -e "102 s/#user =.*/user = postfix/"   \
  -e "103 s/#group =.*/group = postfix/" \
  /etc/dovecot/conf.d/10-master.conf

sed -i -E                                                                        \
 -e "/^ssl_cert/ s|.*|ssl_cert = </etc/letsencrypt/live/$DOMAIN/fullchain.pem|"  \
 -e "/^ssl_key/ s|.*|ssl_key = </etc/letsencrypt/live/$DOMAIN/privkey.pem|"      \
/etc/dovecot/conf.d/10-ssl.conf

# 検証
dovecot -n
systemctl enable dovecot
systemctl start  dovecot

#############
# DKIM 設定 #
#############

##############
# DMARK 設定 #
##############


