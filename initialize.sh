#!/bin/bash -ue

function SYSTEMCTL {
  systemctl stop   "$@" || echo "ERROR"
  systemctl enable "$@" || echo "ERROR"
  systemctl start  "$@" || echo "ERROR"
}

function BK {
  for FILE; do 
    cp -av --backup "$FILE" "$FILE".org
  done
}

function DELETE_ADDCONFIG {
  sed -i  -e "/# ADD CONFIG /,/^$/d" "$1"
}

function COMMENT_OUT {
  FILE="$1"
  shift

  for WORD; do
    sed -i -e "/^$WORD/ s/^/#/g" "$FILE"
  done

  cat "$FILE"
}

function DIFF {
  for FILE; do 
    diff -u "$FILE".org "$FILE"
  done
  
}

# epel repository 追加
dnf -y install epel-release

# crb repository 有効化
dnf config-manager --enable crb

# OS 最新化
dnf -y upgarade

# 追加インストール
# bind-utils : dig 等
# vim      ： EDITOR
# certbot  ： SSH 証明書
# nginx    ： HTTP SERVER
# postfix  ： MAIL SERVER
# dovecot  ： MAIL SERVER
# opendkim ： MAIL SERVER
# opendmarc： MAIL SERVER
dnf -y install vim bind-utils 
dnf -y install certbot nginx
dnf -y install postfix dovecot opendkim opendkim-tools opendmarc

# certbot certonly 
certbot certonly --manual --server https://acme-v02.api.letsencrypt.org/directory \
  --preferred-challenges dns  -d *.$DOMAIN -d $DOMAIN -m $MAIL --agree-tos

##############
# nginx 設定 #
##############
BK /etc/nginx/nginx.conf
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

# 
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
SYSTEMCTL nginx

################
# POSTFIX 設定 #
################
BK /etc/postfix/main.cf \
   /etc/postfix/master.cf

DELETE_ADDCONFIG /etc/postfix/main.cf
COMMENT_OUT /etc/postfix/main.cf \
   myhostname mydomain mydestination myorigin mynetworks     \
   home_mailbox inet_interfaces smtpd_banner syslog_facility \
   disable_vrfy_command smtpd_tls_cert_file smtpd_tls_key_file

cat << __POSTFIX_MAIN__ >> /etc/postfix/main.cf

# ADD CONFIG 
myhostname                        = $MX.$DOMAIN
mydomain                          = $MX.$DOMAIN
myorigin                          = \$myhostname
mydestination                     = \$myhostname, localhost, \$mydomain
inet_interfaces                   = \$myhostname, localhost
mynetworks                        = 127.0.0.0/8
home_mailbox                      = .mail
smtpd_banner                      = \$myhostname ESMTP
message_size_limit                = 10485760
mailbox_size_limit                = 1073741824
syslog_facility                   = mail
disable_vrfy_command              = yes
smtpd_sasl_auth_enable            = yes
smtpd_sasl_type                   = dovecot
smtpd_sasl_path                   = private/auth
broken_sasl_auth_clients          = yes
smtpd_recipient_restrictions      = 
    permit_mynetworks 
    permit_sasl_authenticated 
    reject_unauth_destination
smtpd_tls_cert_file               = /etc/letsencrypt/live/$DOMAIN/fullchain.pem
smtpd_tls_key_file                = /etc/letsencrypt/live/$DOMAIN/privkey.pem
smtpd_tls_session_cache_database  = btree:/var/lib/postfix/smtpd_scache
smtpd_tls_session_cache_timeout   = 3600s
smtpd_tls_received_header         = yes
smtpd_tls_loglevel                = 1

__POSTFIX_MAIN__

sed -i \
    -e "/^#submission/ s/^#//g"  \
    -e "/^#smtps/      s/^#//g"  \
    -e "31,32          s/^#/ /g" \
    -e "38             s/^#/ /g" \
  /etc/postfix/master.cf

# 検証
postfix check

################
# DOVECOT 設定 #
################
BK /etc/dovecot/conf.d/10-master.conf
BK /etc/dovecot/conf.d/10-ssl.conf

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
 -e "/^ssl_key/  s|.*|ssl_key = </etc/letsencrypt/live/$DOMAIN/privkey.pem|"     \
/etc/dovecot/conf.d/10-ssl.conf

# 検証
dovecot -n

#############
# DKIM 設定 #
#############
BK /etc/opendkim.conf

DELETE_ADDCONFIG  /etc/opendkim.conf
COMMENT_OUT       /etc/opendkim.conf  \
  Mode UserID KeyFile Domain

cat << __CONF__ >> /etc/opendkim.conf
# ADD CONFIG 
Mode      sv
UserID    postfix:postfix
Domain    $DOMAIN
KeyFile   /etc/opendkim/keys/$MX.private

__CONF__

DIFF /etc/opendkim.conf

opendkim-genkey -D /etc/opendkim/keys -b 2048 -d $DOMAIN -s $MX
hown postfix:postfix  /*/opendkim* -Rv

cat << __POSTFIX_MAIN__ >> /etc/postfix/main.cf

# ADD CONFIG （DKIM）
smtpd_milters = inet:localhost:8891
non_smtpd_milters = inet:localhost:8891
milter_default_action = accept

__POSTFIX_MAIN__

BK /usr/lib/systemd/system/opendkim.service
sed -i \
    -e "/^User/  s/.*/User=postfix/"  \
    -e "/^Group/ s/.*/Group=postfix/" \
  /usr/lib/systemd/system/opendkim.service

postfix check

##############
# DMARK 設定 #
##############
BK /etc/opendmarc.conf

cat << __POSTFIX_MAIN__ >> /etc/opendmarc.conf

# ADD CONFIG 
AuthservID                  OpenDMARC
RejectFailures              false
TrustedAuthservIDs          $MX.$DOMAIN
UserID                      postfix:postfix
IgnoreHosts                 /etc/opendmarc/ignore.hosts
IgnoreAuthenticatedClients  true
RequiredHeaders             true

__POSTFIX_MAIN__

touch  /etc/opendmarc/ignore.hosts
chown postfix:postfix  /*/opendmarc* -Rv


BK /usr/lib/systemd/system/opendmarc.service
sed -i \
    -e "/^User/  s/.*/User=postfix/"  \
    -e "/^Group/ s/.*/Group=postfix/" \
  /usr/lib/systemd/system/opendmarc.service

######################
# メールサーバー 設定 #
######################


SYSTEMCTL postfix dovecot opendkim opendmarc

cat << __ECHO__ 
DNS : _dmarc.$MX.$dOMAIN
TXT : v=DMARC1; p=quarantine; adkim=s; aspf=s
__EcHO__
