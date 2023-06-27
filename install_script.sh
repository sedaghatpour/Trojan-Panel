#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# System Required: CentOS 7+/Ubuntu 18+/Debian 10+
# Version: v2.2.1
# Description: One click Install Trojan Panel server
# Author: sedaghatpour <https://jsedaghatpour.com>
# Github: https://github.com/sedaghatpour/install-script

init_var() {
  ECHO_TYPE="echo -e"

  package_manager=""
  release=""
  get_arch=""
  can_google=0

  # Docker
  DOCKER_MIRROR='"https://hub-mirror.c.163.com","https://ccr.ccs.tencentyun.com","https://mirror.baidubce.com","https://dockerproxy.com"'

  # 项目目录
  TP_DATA="/tpdata/"

  STATIC_HTML="https://github.com/sedaghatpour/install-script/releases/download/v1.0.0/html.tar.gz"

  # web
  WEB_PATH="/tpdata/web/"

  # cert
  CERT_PATH="/tpdata/cert/"
  DOMAIN_FILE="/tpdata/domain.lock"
  domain=""
  crt_path=""
  key_path=""

  # Caddy
  CADDY_DATA="/tpdata/caddy/"
  CADDY_CONFIG="${CADDY_DATA}config.json"
  CADDY_LOG="${CADDY_DATA}logs/"
  CADDY_CERT_DIR="${CERT_PATH}certificates/acme-v02.api.letsencrypt.org-directory/"
  caddy_port=80
  caddy_remote_port=8863
  your_email=""
  ssl_option=1
  ssl_module_type=1
  ssl_module="acme"

  # Nginx
  NGINX_DATA="/tpdata/nginx/"
  NGINX_CONFIG="${NGINX_DATA}default.conf"
  nginx_port=80
  nginx_remote_port=8863
  nginx_https=1

  # MariaDB
  MARIA_DATA="/tpdata/mariadb/"
  mariadb_ip="127.0.0.1"
  mariadb_port=9507
  mariadb_user="root"
  mariadb_pas=""

  #Redis
  REDIS_DATA="/tpdata/redis/"
  redis_host="127.0.0.1"
  redis_port=6378
  redis_pass=""

  # Trojan Panel前端
  TROJAN_PANEL_UI_DATA="/tpdata/trojan-panel-ui/"
  # Nginx
  UI_NGINX_DATA="${TROJAN_PANEL_UI_DATA}nginx/"
  UI_NGINX_CONFIG="${UI_NGINX_DATA}default.conf"
  trojan_panel_ui_port=2083
  ui_https=1
  trojan_panel_ip="127.0.0.1"
  trojan_panel_server_port=8081

  # Trojan Panel后端
  TROJAN_PANEL_DATA="/tpdata/trojan-panel/"
  TROJAN_PANEL_WEBFILE="${TROJAN_PANEL_DATA}webfile/"
  TROJAN_PANEL_LOGS="${TROJAN_PANEL_DATA}logs/"
  TROJAN_PANEL_CONFIG="${TROJAN_PANEL_DATA}config/"
  trojan_panel_config_path="${TROJAN_PANEL_DATA}config/config.ini"
  trojan_panel_port=8081

  # Trojan Panel内核
  TROJAN_PANEL_CORE_DATA="/tpdata/trojan-panel-core/"
  TROJAN_PANEL_CORE_LOGS="${TROJAN_PANEL_CORE_DATA}logs/"
  TROJAN_PANEL_CORE_CONFIG="${TROJAN_PANEL_CORE_DATA}config/"
  trojan_panel_core_config_path="${TROJAN_PANEL_CORE_DATA}config/config.ini"
  database="trojan_panel_db"
  account_table="account"
  grpc_port=8100
  trojan_panel_core_port=8082

  # Update
  trojan_panel_ui_current_version=""
  trojan_panel_ui_latest_version="v2.1.5"
  trojan_panel_current_version=""
  trojan_panel_latest_version="v2.1.4"
  trojan_panel_core_current_version=""
  trojan_panel_core_latest_version="v2.1.1"

  # SQL
  sql_200="alter table \`system\` add template_config varchar(512) default '' not null comment 'template setting' after email_config;update \`system\` set template_config = \"{\\\"systemName\\\":\\\"Trojan Panel\\\"}\" where name = \"trojan-panel\";insert into \`casbin_rule\` values ('p','sysadmin','/api/nodeServer/nodeServerState','GET','','','');insert into \`casbin_rule\` values ('p','user','/api/node/selectNodeInfo','GET','','','');insert into \`casbin_rule\` values ('p','sysadmin','/api/node/selectNodeInfo','GET','','','');"
  sql_203="alter table node add node_server_grpc_port int(10) unsigned default 8100 not null comment 'gRPC port' after node_server_ip;alter table node_server add grpc_port int(10) unsigned default 8100 not null comment 'gRPC port' after name;alter table node_xray add xray_flow varchar(32) default 'xtls-rprx-vision' not null comment 'Xray flow control after protocol;alter table node_xray add xray_ss_method varchar(32) default 'aes-256-gcm' not null comment 'Xray Shadowsocks encryption method' after xray_flow;"
  sql_205="DROP TABLE IF EXISTS \`file_task\`;CREATE TABLE \`file_task\` ( \`id\` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'auto increment primary key', \`name\` varchar(64) NOT NULL DEFAULT '' COMMENT 'file name', \`path\` varchar(128) NOT NULL DEFAULT '' COMMENT 'file path', \`type\` tinyint(2) unsigned NOT NULL DEFAULT '1' COMMENT 'Type 1/User Import 2/Server Import 3/User Export 4/Server Export', \`status\` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Status -1/Failed 0/Waiting 1/Executing 2/Success', \`err_msg\` varchar(128) NOT NULL DEFAULT '' COMMENT 'error message, \`account_id\` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT 'account id', \`account_username\` varchar(64) NOT NULL DEFAULT '' COMMENT 'Account login username', \`create_time\` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'creation time', \`update_time\` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'update time', PRIMARY KEY (\`id\`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='file task';INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/account/exportAccount', 'POST', '', '', '');INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/account/importAccount', 'POST', '', '', '');INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/system/uploadLogo', 'POST', '', '', '');INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/nodeServer/exportNodeServer', 'POST', '', '', '');INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/nodeServer/importNodeServer', 'POST', '', '', '');INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/fileTask/selectFileTaskPage', 'GET', '', '', '');INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/fileTask/deleteFileTaskById', 'POST', '', '', '');INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/fileTask/downloadFileTask', 'POST', '', '', '');INSERT INTO trojan_panel_db.casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/fileTask/downloadCsvTemplate', 'POST', '', '', '');"
  sql_210="UPDATE casbin_rule SET v1 = '/api/fileTask/downloadTemplate' WHERE v1 = '/api/fileTask/downloadCsvTemplate';UPDATE casbin_rule SET v1 = '/api/account/updateAccountPass' WHERE v1 = '/api/account/updateAccountProfile';INSERT INTO casbin_rule (p_type, v0, v1, v2) VALUES ('p', 'sysadmin', '/api/account/updateAccountProperty', 'POST');INSERT INTO casbin_rule (p_type, v0, v1, v2) VALUES ('p', 'user', '/api/account/updateAccountProperty', 'POST');alter table node_xray modify settings varchar(1024) default '' not null comment 'settings';alter table node_xray modify stream_settings varchar(1024) default '' not null comment 'streamSettings';alter table node_xray add reality_pbk varchar(64) default '' not null comment 'public key of reality' after xray_ss_method;alter table node_hysteria add obfs varchar(64) default '' not null comment 'obfuscated password' after protocol;"
  sql_211="UPDATE \`system\` SET account_config = '{\"registerEnable\":1,\"registerQuota\":0,\"registerExpireDays\":0,\"resetDownloadAndUploadMonth\":0,\"trafficRankEnable\":1,\"captchaEnable\":0}' WHERE name = 'trojan-panel';INSERT INTO casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/node/nodeDefault', 'GET', '', '', '');INSERT INTO casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'user', '/api/node/nodeDefault', 'GET', '', '', '');"
  sql_212="alter table account add validity_period int unsigned default 0 not null comment 'account validity period' after email;alter table account add last_login_time bigint unsigned default 0 not null comment 'last login time' after validity_period;INSERT INTO casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/account/createAccountBatch', 'POST', '', '', '');INSERT INTO casbin_rule (p_type, v0, v1, v2, v3, v4, v5) VALUES ('p', 'sysadmin', '/api/account/exportAccountUnused', 'POST', '', '', '');"
}

echo_content() {
  case $1 in
  "red")
    ${ECHO_TYPE} "\033[31m$2\033[0m"
    ;;
  "green")
    ${ECHO_TYPE} "\033[32m$2\033[0m"
    ;;
  "yellow")
    ${ECHO_TYPE} "\033[33m$2\033[0m"
    ;;
  "blue")
    ${ECHO_TYPE} "\033[34m$2\033[0m"
    ;;
  "purple")
    ${ECHO_TYPE} "\033[35m$2\033[0m"
    ;;
  "skyBlue")
    ${ECHO_TYPE} "\033[36m$2\033[0m"
    ;;
  "white")
    ${ECHO_TYPE} "\033[37m$2\033[0m"
    ;;
  esac
}

mkdir_tools() {
  # 项目目录
  mkdir -p ${TP_DATA}

  # web
  mkdir -p ${WEB_PATH}

  # cert
  mkdir -p ${CERT_PATH}
  touch ${DOMAIN_FILE}

  # Caddy
  mkdir -p ${CADDY_DATA}
  touch ${CADDY_CONFIG}
  mkdir -p ${CADDY_LOG}

  # Nginx
  mkdir -p ${NGINX_DATA}
  touch ${NGINX_CONFIG}

  # MariaDB
  mkdir -p ${MARIA_DATA}

  # Redis
  mkdir -p ${REDIS_DATA}

  # Trojan Panel前端
  mkdir -p ${TROJAN_PANEL_UI_DATA}
  # # Nginx
  mkdir -p ${UI_NGINX_DATA}
  touch ${UI_NGINX_CONFIG}

  # Trojan Panel后端
  mkdir -p ${TROJAN_PANEL_DATA}
  mkdir -p ${TROJAN_PANEL_LOGS}

  # Trojan Panel内核
  mkdir -p ${TROJAN_PANEL_CORE_DATA}
  mkdir -p ${TROJAN_PANEL_CORE_LOGS}
}

can_connect() {
  ping -c2 -i0.3 -W1 "$1" &>/dev/null
  if [[ "$?" == "0" ]]; then
    return 0
  else
    return 1
  fi
}

get_ini_value() {
  local config_file="$1"
  local key="$2"
  local section=""
  local section_flag=0

  # 拆分组名和键名
  IFS='.' read -r group_name key_name <<<"$key"

  while IFS='=' read -r name val; do
    # 处理节名称
    if [[ $name =~ ^\[(.*)\]$ ]]; then
      section="${BASH_REMATCH[1]}"
      if [[ $section == $group_name ]]; then
        section_flag=1
      else
        section_flag=0
      fi
      continue
    fi

    # 提取配置项的值
    if [[ $section_flag -eq 1 && $name == $key_name ]]; then
      echo "$val"
      return
    fi
  done <"$config_file"
}

check_sys() {
  if [[ $(command -v yum) ]]; then
    package_manager='yum'
  elif [[ $(command -v dnf) ]]; then
    package_manager='dnf'
  elif [[ $(command -v apt) ]]; then
    package_manager='apt'
  elif [[ $(command -v apt-get) ]]; then
    package_manager='apt-get'
  fi

  if [[ -z "${package_manager}" ]]; then
    echo_content red "This system is not currently supported"
    exit 0
  fi

  if [[ -n $(find /etc -name "redhat-release") ]] || grep </proc/version -q -i "centos"; then
    release="centos"
  elif grep </etc/issue -q -i "debian" && [[ -f "/etc/issue" ]] || grep </etc/issue -q -i "debian" && [[ -f "/proc/version" ]]; then
    release="debian"
  elif grep </etc/issue -q -i "ubuntu" && [[ -f "/etc/issue" ]] || grep </etc/issue -q -i "ubuntu" && [[ -f "/proc/version" ]]; then
    release="ubuntu"
  fi

  if [[ -z "${release}" ]]; then
    echo_content red "Only supports CentOS 7+/Ubuntu 18+/Debian 10+ systems"
    exit 0
  fi

  if [[ $(arch) =~ ("x86_64"|"amd64"|"arm64"|"aarch64"|"arm"|"s390x") ]]; then
    get_arch=$(arch)
  fi

  if [[ -z "${get_arch}" ]]; then
    echo_content red "Only supports amd64/arm64/arm/s390x processor architecture"
    exit 0
  fi

  can_connect www.google.com
  [[ "$?" == "0" ]] && can_google=1
}

depend_install() {
  if [[ "${package_manager}" != 'yum' && "${package_manager}" != 'dnf' ]]; then
    ${package_manager} update -y
  fi
  ${package_manager} install -y \
    curl \
    wget \
    tar \
    lsof \
    systemd
}

# Install Docker
install_docker() {
  if [[ ! $(docker -v 2>/dev/null) ]]; then
    echo_content green "---> Installing Docker"

    # Disable Firewall
    if [[ "$(firewall-cmd --state 2>/dev/null)" == "running" ]]; then
      systemctl stop firewalld.service && systemctl disable firewalld.service
    fi

    # Timezone
    timedatectl set-timezone Asia/Shanghai

    if [[ ${can_google} == 0 ]]; then
      sh <(curl -sL https://get.docker.com) --mirror Aliyun
      # Set Docker's Chinese mirror
      mkdir -p /etc/docker &&
        cat >/etc/docker/daemon.json <<EOF
{
  "registry-mirrors":[${DOCKER_MIRROR}],
  "log-driver":"json-file",
  "log-opts":{
      "max-size":"50m",
      "max-file":"3"
  }
}
EOF
    else
      sh <(curl -sL https://get.docker.com)
      mkdir -p /etc/docker &&
        cat >/etc/docker/daemon.json <<EOF
{
  "log-driver":"json-file",
  "log-opts":{
      "max-size":"50m",
      "max-file":"3"
  }
}
EOF
    fi

    systemctl enable docker &&
      systemctl restart docker

    if [[ $(docker -v 2>/dev/null) ]]; then
      echo_content skyBlue "---> Docker installation completed"
    else
      echo_content red "---> Docker installation failed"
      exit 0
    fi
  else
    echo_content skyBlue "---> Docker is already installed"
  fi
}

# Install Caddy2
install_caddy2() {
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-caddy$") ]]; then
    echo_content green "---> Installing Caddy2"

    wget --no-check-certificate -O ${WEB_PATH}html.tar.gz -N ${STATIC_HTML} &&
      tar -zxvf ${WEB_PATH}html.tar.gz -k -C ${WEB_PATH}

    read -r -p "Enter Caddy port (default: 80): " caddy_port
    [[ -z "${caddy_port}" ]] && caddy_port=80
    read -r -p "Enter Caddy remote port (default: 8863): " caddy_remote_port
    [[ -z "${caddy_remote_port}" ]] && caddy_remote_port=8863

    echo_content yellow "Note: Please make sure that the domain name has been resolved to this machine, otherwise installation may fail."
    while read -r -p "Enter your domain name (required): " domain; do
      if [[ -z "${domain}" ]]; then
        echo_content red "Domain name cannot be empty"
      else
        break
      fi
    done

    read -r -p "Enter your email (optional): " your_email

    while read -r -p "Please select how to set up the certificate? (1/automatic application and renewal of certificates, 2/manually set the certificate path, default: 1/automatic): " ssl_option; do
      if [[ -z ${ssl_option} || ${ssl_option} == 1 ]]; then
        while read -r -p "Please select the way to apply for the certificate (1/acme, 2/zerossl, default: 1/acme): " ssl_module_type; do
          if [[ -z "${ssl_module_type}" || ${ssl_module_type} == 1 ]]; then
            ssl_module="acme"
            CADDY_CERT_DIR="${CERT_PATH}certificates/acme-v02.api.letsencrypt.org-directory/"
            break
          elif [[ ${ssl_module_type} == 2 ]]; then
            ssl_module="zerossl"
            CADDY_CERT_DIR="${CERT_PATH}certificates/acme.zerossl.com-v2-dv90/"
            break
          else
            echo_content red "You cannot enter any characters other than 1 and 2."
          fi
        done

        cat >${CADDY_CONFIG} <<EOF
{
    "admin":{
        "disabled":true
    },
    "logging":{
        "logs":{
            "default":{
                "writer":{
                    "output":"file",
                    "filename":"${CADDY_LOG}error.log"
                },
                "level":"ERROR"
            }
        }
    },
    "storage":{
        "module":"file_system",
        "root":"${CERT_PATH}"
    },
    "apps":{
        "http":{
            "http_port": ${caddy_port},
            "servers":{
                "srv0":{
                    "listen":[
                        ":${caddy_port}"
                    ],
                    "routes":[
                        {
                            "match":[
                                {
                                    "host":[
                                        "${domain}"
                                    ]
                                }
                            ],
                            "handle":[
                                {
                                    "handler":"static_response",
                                    "headers":{
                                        "Location":[
                                            "https://{http.request.host}:${caddy_remote_port}{http.request.uri}"
                                        ]
                                    },
                                    "status_code":301
                                }
                            ]
                        }
                    ]
                },
                "srv1":{
                    "listen":[
                        ":${caddy_remote_port}"
                    ],
                    "routes":[
                        {
                            "handle":[
                                {
                                    "handler":"subroute",
                                    "routes":[
                                        {
                                            "match":[
                                                {
                                                    "host":[
                                                        "${domain}"
                                                    ]
                                                }
                                            ],
                                            "handle":[
                                                {
                                                    "handler":"file_server",
                                                    "root":"${WEB_PATH}",
                                                    "index_names":[
                                                        "index.html",
                                                        "index.htm"
                                                    ]
                                                }
                                            ],
                                            "terminal":true
                                        }
                                    ]
                                }
                            ]
                        }
                    ],
                    "tls_connection_policies":[
                        {
                            "match":{
                                "sni":[
                                    "${domain}"
                                ]
                            }
                        }
                    ],
                    "automatic_https":{
                        "disable":true
                    }
                }
            }
        },
        "tls":{
            "certificates":{
                "automate":[
                    "${domain}"
                ]
            },
            "automation":{
                "policies":[
                    {
                        "issuers":[
                            {
                                "module":"${ssl_module}",
                                "email":"${your_email}"
                            }
                        ]
                    }
                ]
            }
        }
    }
}
EOF
        break
      elif [[ ${ssl_option} == 2 ]]; then
        install_custom_cert "${domain}"
        cat >${CADDY_CONFIG} <<EOF
{
    "admin":{
        "disabled":true
    },
    "logging":{
        "logs":{
            "default":{
                "writer":{
                    "output":"file",
                    "filename":"${CADDY_LOG}error.log"
                },
                "level":"ERROR"
            }
        }
    },
    "storage":{
        "module":"file_system",
        "root":"${CERT_PATH}"
    },
    "apps":{
        "http":{
            "http_port": ${caddy_port},
            "servers":{
                "srv0":{
                    "listen":[
                        ":${caddy_port}"
                    ],
                    "routes":[
                        {
                            "match":[
                                {
                                    "host":[
                                        "${domain}"
                                    ]
                                }
                            ],
                            "handle":[
                                {
                                    "handler":"static_response",
                                    "headers":{
                                        "Location":[
                                            "https://{http.request.host}:${caddy_remote_port}{http.request.uri}"
                                        ]
                                    },
                                    "status_code":301
                                }
                            ]
                        }
                    ]
                },
                "srv1":{
                    "listen":[
                        ":${caddy_remote_port}"
                    ],
                    "routes":[
                        {
                            "handle":[
                                {
                                    "handler":"subroute",
                                    "routes":[
                                        {
                                            "match":[
                                                {
                                                    "host":[
                                                        "${domain}"
                                                    ]
                                                }
                                            ],
                                            "handle":[
                                                {
                                                    "handler":"file_server",
                                                    "root":"${WEB_PATH}",
                                                    "index_names":[
                                                        "index.html",
                                                        "index.htm"
                                                    ]
                                                }
                                            ],
                                            "terminal":true
                                        }
                                    ]
                                }
                            ]
                        }
                    ],
                    "tls_connection_policies":[
                        {
                            "match":{
                                "sni":[
                                    "${domain}"
                                ]
                            }
                        }
                    ],
                    "automatic_https":{
                        "disable":true
                    }
                }
            }
        },
        "tls":{
            "certificates":{
                "automate":[
                    "${domain}"
                ],
                "load_files":[
                    {
                        "certificate":"${CADDY_CERT_DIR}${domain}/${domain}.crt",
                        "key":"${CADDY_CERT_DIR}${domain}/${domain}.key"
                    }
                ]
            },
            "automation":{
                "policies":[
                    {
                        "issuers":[
                            {
                                "module":"${ssl_module}",
                                "email":"${your_email}"
                            }
                        ]
                    }
                ]
            }
        }
    }
}
EOF
        break
      else
        echo_content red "You cannot enter any character other than 1 and 2."
      fi
    done

    if [[ -n $(lsof -i:${caddy_port},443 -t) ]]; then
      kill -9 "$(lsof -i:${caddy_port},443 -t)"
    fi

    docker pull caddy:2.6.2 &&
      docker run -d --name trojan-panel-caddy --restart always \
        --network=host \
        -v "${CADDY_CONFIG}":"${CADDY_CONFIG}" \
        -v ${CERT_PATH}:"${CADDY_CERT_DIR}${domain}/" \
        -v ${WEB_PATH}:${WEB_PATH} \
        -v ${CADDY_LOG}:${CADDY_LOG} \
        caddy:2.6.2 caddy run --config ${CADDY_CONFIG}

    if [[ -n $(docker ps -q -f "name=^trojan-panel-caddy$" -f "status=running") ]]; then
      cat >${DOMAIN_FILE} <<EOF
${domain}
EOF
      echo_content skyBlue "---> Caddy installation completed."
    else
      echo_content red "---> Failed to install Caddy or it is not running properly. Please try to fix it or uninstall and reinstall."
      exit 0
    fi
  else
    echo_content skyBlue "---> You have already installed Caddy."
  fi
}

# Install Nginx
install_nginx() {
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-nginx$") ]]; then
    echo_content green "---> Installing Nginx."

    wget --no-check-certificate -O ${WEB_PATH}html.tar.gz -N ${STATIC_HTML} &&
      tar -zxvf ${WEB_PATH}html.tar.gz -k -C ${WEB_PATH}

    read -r -p "Please enter the port for Nginx (default: 80): " nginx_port
    [[ -z "${nginx_port}" ]] && nginx_port=80
    read -r -p "Please enter the forwarding port for Nginx (default: 8863): " nginx_remote_port
    [[ -z "${nginx_remote_port}" ]] && nginx_remote_port=8863

    while read -r -p "Do you want to enable https for Nginx? (0/disable 1/enable, default: 1/enable): " nginx_https; do
      if [[ -z ${nginx_https} || ${nginx_https} == 1 ]]; then
        install_custom_cert "custom_cert"
        domain=$(cat "${DOMAIN_FILE}")
        cat >${NGINX_CONFIG} <<-EOF
server {
    listen ${nginx_port};
    server_name localhost;

    return 301 http://\$host:${nginx_remote_port}\$request_uri;
}

server {
    listen       ${nginx_remote_port} ssl;
    server_name  localhost;

    #Force SSL
    ssl on;
    ssl_certificate      ${CERT_PATH}${domain}.crt;
    ssl_certificate_key  ${CERT_PATH}${domain}.key;
    #Cache expiration time
    ssl_session_timeout  5m;
    #Secure link optional encryption protocol
    ssl_protocols  TLSv1.3;
    #Encryption algorithm
    ssl_ciphers  ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    #Use server preferred algorithm    
    ssl_prefer_server_ciphers  on;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   ${WEB_PATH};
        index  index.html index.htm;
    }

    #error_page  404              /404.html;
    #497 http->https
    error_page  497               https://\$host:${nginx_remote_port}\$request_uri;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
        break
      else
        if [[ ${nginx_https} != 0 ]]; then
          echo_content red "You cannot enter any character other than 0 and 1."
        else
          cat >${NGINX_CONFIG} <<-EOF
server {
    listen       ${nginx_port};
    server_name  localhost;

    location / {
        root   ${WEB_PATH};
        index  index.html index.htm;
    }

    error_page  497               http://\$host:${nginx_port}\$request_uri;

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
          break
        fi
      fi
    done

    docker pull nginx:1.20-alpine &&
      docker run -d --name trojan-panel-nginx --restart always \
        --network=host \
        -v "${NGINX_CONFIG}":"/etc/nginx/conf.d/default.conf" \
        -v ${CERT_PATH}:${CERT_PATH} \
        -v ${WEB_PATH}:${WEB_PATH} \
        nginx:1.20-alpine

    if [[ -n $(docker ps -q -f "name=^trojan-panel-nginx$" -f "status=running") ]]; then
      echo_content skyBlue "---> Nginx installation completed."
    else
      echo_content red "---> Failed to install Nginx or it is not running properly. Please try to fix it or uninstall and reinstall."
      exit 0
    fi
  else
    echo_content skyBlue "---> You have installed Nginx"
  fi
}

# Set up reverse proxy
install_reverse_proxy() {
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-caddy$|^trojan-panel-nginx$") ]]; then
    echo_content green "---> Setting up reverse proxy."

    while :; do
      echo_content yellow "1. Install Caddy 2 (recommended)."
      echo_content yellow "2. Install Nginx."
      echo_content yellow "3. Do not set up reverse proxy."
      read -r -p "Please select an option (default: 1): " whether_install_reverse_proxy
      [[ -z "${whether_install_reverse_proxy}" ]] && whether_install_reverse_proxy=1

      case ${whether_install_reverse_proxy} in
      1)
        install_caddy2
        break
        ;;
      2)
        install_nginx
        break
        ;;
      3)
        break
        ;;
      *)
        echo_content red "Invalid option."
        continue
        ;;
      esac
    done

    echo_content skyBlue "---> Reverse proxy setup completed."
  fi
}

install_custom_cert() {
  while read -r -p "Please enter the .crt file path of the certificate (required): " crt_path; do
    if [[ -z "${crt_path}" ]]; then
      echo_content red "path cannot be empty"
    else
      if [[ ! -f "${crt_path}" ]]; then
        echo_content red "The .crt file path for the certificate does not exist"
      else
        cp "${crt_path}" "${CERT_PATH}$1.crt"
        break
      fi
    fi
  done
  while read -r -p "Please enter the .key file path of the certificate (required): " key_path; do
    if [[ -z "${key_path}" ]]; then
      echo_content red "path cannot be empty"
    else
      if [[ ! -f "${key_path}" ]]; then
        echo_content red "The .key file path of the certificate does not exist"
      else
        cp "${key_path}" "${CERT_PATH}$1.key"
        break
      fi
    fi
  done
  cat >${DOMAIN_FILE} <<EOF
$1
EOF
}

# Set up certificate
install_cert() {
  domain=$(cat "${DOMAIN_FILE}")
  if [[ -z "${domain}" ]]; then
    echo_content green "---> Setting up certificate."

    while :; do
      echo_content yellow "1. Install Caddy 2 (automatic certificate issuance/renewal)."
      echo_content yellow "2. Manually set certificate path."
      echo_content yellow "3. Do not set up certificate."
      read -r -p "Please select an option (default: 1): " whether_install_cert
      [[ -z "${whether_install_cert}" ]] && whether_install_cert=1

      case ${whether_install_cert} in
      1)
        install_caddy2
        break
        ;;
      2)
        install_custom_cert "custom_cert"
        break
        ;;
      3)
        break
        ;;
      *)
        echo_content red "Invalid option."
        continue
        ;;
      esac
    done

    echo_content green "---> Certificate setup completed."
  fi
}

# Install MariaDB
install_mariadb() {
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-mariadb$") ]]; then
    echo_content green "---> Installing MariaDB."

    read -r -p "Please enter the port number for the database (default: 9507): " mariadb_port
    [[ -z "${mariadb_port}" ]] && mariadb_port=9507
    read -r -p "Please enter the username for the database (default: root): " mariadb_user
    [[ -z "${mariadb_user}" ]] && mariadb_user="root"
    while read -r -p "Please enter the password for the database (required): " mariadb_pas; do
      if [[ -z "${mariadb_pas}" ]]; then
        echo_content red "Password cannot be empty."
      else
        break
      fi
    done

    if [[ "${mariadb_user}" == "root" ]]; then
      docker pull mariadb:10.7.3 &&
        docker run -d --name trojan-panel-mariadb --restart always \
          --network=host \
          -e MYSQL_DATABASE="trojan_panel_db" \
          -e MYSQL_ROOT_PASSWORD="${mariadb_pas}" \
          -e TZ=Asia/Shanghai \
          mariadb:10.7.3 \
          --port ${mariadb_port} \
          --character-set-server=utf8mb4 \
          --collation-server=utf8mb4_unicode_ci
    else
      docker pull mariadb:10.7.3 &&
        docker run -d --name trojan-panel-mariadb --restart always \
          --network=host \
          -e MYSQL_DATABASE="trojan_panel_db" \
          -e MYSQL_ROOT_PASSWORD="${mariadb_pas}" \
          -e MYSQL_USER="${mariadb_user}" \
          -e MYSQL_PASSWORD="${mariadb_pas}" \
          -e TZ=Asia/Shanghai \
          mariadb:10.7.3 \
          --port ${mariadb_port} \
          --character-set-server=utf8mb4 \
          --collation-server=utf8mb4_unicode_ci
    fi

    if [[ -n $(docker ps -q -f "name=^trojan-panel-mariadb$" -f "status=running") ]]; then
      echo_content skyBlue "---> MariaDB installation completed."
      echo_content yellow "---> MariaDB root database password (please keep it safe): ${mariadb_pas}"
      if [[ "${mariadb_user}" != "root" ]]; then
        echo_content yellow "---> MariaDB ${mariadb_user}'s database password (please keep it safe): ${mariadb_pas}"
      fi
    else
      echo_content red "---> Failed to install MariaDB or it is not running properly. Please try to fix it or reinstall."
      exit 0
    fi
  else
    echo_content skyBlue "---> You have already installed MariaDB."
  fi
}

# Install Redis
install_redis() {
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-redis$") ]]; then
    echo_content green "---> Installing Redis."

    read -r -p "Please enter the port number for Redis (default: 6378): " redis_port
    [[ -z "${redis_port}" ]] && redis_port=6378
    while read -r -p "Please enter the password for Redis (required): " redis_pass; do
      if [[ -z "${redis_pass}" ]]; then
        echo_content red "Password cannot be empty."  
      else
        break
      fi
    done

    docker pull redis:6.2.7 &&
      docker run -d --name trojan-panel-redis --restart always \
        --network=host \
        redis:6.2.7 \
        redis-server --requirepass "${redis_pass}" --port "${redis_port}"

    if [[ -n $(docker ps -q -f "name=^trojan-panel-redis$" -f "status=running") ]]; then
      echo_content skyBlue "---> Redis installation completed."
      echo_content yellow "---> Redis database password (please keep it safe): ${redis_pass}"
    else
      echo_content red "---> Failed to install Redis or it is not running properly. Please try to fix it or reinstall."
      exit 0
    fi
  else
    echo_content skyBlue "---> You have already installed Redis."
  fi
}

# Install Trojan Panel frontend
install_trojan_panel_ui() {
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-ui$") ]]; then
    echo_content green "---> Installing Trojan Panel frontend."

    read -r -p "Please enter the IP address of your Trojan Panel backend (default: local backend): " trojan_panel_ip
    [[ -z "${trojan_panel_ip}" ]] && trojan_panel_ip="127.0.0.1"
    read -r -p "Please enter the service port of your Trojan Panel backend (default: 8081): " trojan_panel_server_port
    [[ -z "${trojan_panel_server_port}" ]] && trojan_panel_server_port=8081

    read -r -p "Please enter the port of your Trojan Panel frontend (default: 2083): " trojan_panel_ui_port
    [[ -z "${trojan_panel_ui_port}" ]] && trojan_panel_ui_port="2083"
    while read -r -p "Please choose whether to enable https for Trojan Panel frontend? (0/disable, 1/enable, default: 1/enable): " ui_https; do
      if [[ -z ${ui_https} || ${ui_https} == 1 ]]; then
        install_cert
        domain=$(cat "${DOMAIN_FILE}")
        # 配置Nginx
        cat >${UI_NGINX_CONFIG} <<-EOF
server {
    listen       ${trojan_panel_ui_port} ssl;
    server_name  localhost;

    # Force SSL
    ssl on;
    ssl_certificate      ${CERT_PATH}${domain}.crt;
    ssl_certificate_key  ${CERT_PATH}${domain}.key;
    # Caching validity period
    ssl_session_timeout  5m;
    # Optional encryption protocol for secure links
    ssl_protocols  TLSv1.3;
    # Encryption algorithm
    ssl_ciphers  ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
    # Use the preferred algorithm on the server side
    ssl_prefer_server_ciphers  on;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   ${TROJAN_PANEL_UI_DATA};
        index  index.html index.htm;
    }

    location /api {
        proxy_pass http://${trojan_panel_ip}:${trojan_panel_server_port};
    }

    #error_page  404              /404.html;
    #497 http->https
    error_page  497               https://\$host:${trojan_panel_ui_port}\$request_uri;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
        break
      else
        if [[ ${ui_https} != 0 ]]; then
          echo_content red "You cannot enter any characters other than 0 and 1."
        else
          cat >${UI_NGINX_CONFIG} <<-EOF
server {
    listen       ${trojan_panel_ui_port};
    server_name  localhost;

    location / {
        root   ${TROJAN_PANEL_UI_DATA};
        index  index.html index.htm;
    }

    location /api {
        proxy_pass http://${trojan_panel_ip}:${trojan_panel_server_port};
    }

    error_page  497               http://\$host:${trojan_panel_ui_port}\$request_uri;

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
          break
        fi
      fi
    done

    docker pull jonssonyan/trojan-panel-ui &&
      docker run -d --name trojan-panel-ui --restart always \
        --network=host \
        -v "${UI_NGINX_CONFIG}":"/etc/nginx/conf.d/default.conf" \
        -v ${CERT_PATH}:${CERT_PATH} \
        jonssonyan/trojan-panel-ui

    if [[ -n $(docker ps -q -f "name=^trojan-panel-ui$" -f "status=running") ]]; then
      echo_content skyBlue "---> Trojan Panel frontend installation completed."

      https_flag=$([[ -z ${ui_https} || ${ui_https} == 1 ]] && echo "https" || echo "http")
      domain_or_ip=$([[ -z ${domain} || "${domain}" == "custom_cert" ]] && echo "ip" || echo "${domain}")

      echo_content red "\n=============================================================="
      echo_content skyBlue "Trojan Panel frontend installed successfully."
      echo_content yellow "Management panel address: ${https_flag}://${domain_or_ip}:${trojan_panel_ui_port}"
      echo_content red "\n=============================================================="
    else
      echo_content red "---> Failed to install Trojan Panel frontend or it is not running properly. Please try to fix it or reinstall."
      exit 0
    fi
  else
    echo_content skyBlue "---> You have installed the Trojan Panel frontend"
  fi
}

# Install Trojan Panel backend
install_trojan_panel() {
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel$") ]]; then
    echo_content green "---> Installing Trojan Panel backend."

    read -r -p "Please enter the service port for Trojan Panel backend (default: 8081): " trojan_panel_port
    [[ -z "${trojan_panel_port}" ]] && trojan_panel_port=8081
    
    read -r -p "Please enter the IP address of your MariaDB database (default: local database): " mariadb_ip
    [[ -z "${mariadb_ip}" ]] && mariadb_ip="127.0.0.1"
    read -r -p "Please enter the port of your MariaDB database (default: 9507): " mariadb_port
    [[ -z "${mariadb_port}" ]] && mariadb_port=9507
    read -r -p "Please enter the username of your MariaDB database (default: root): " mariadb_user
    [[ -z "${mariadb_user}" ]] && mariadb_user="root"
    while read -r -p "Please enter the password of your MariaDB database (required): " mariadb_pas; do
      if [[ -z "${mariadb_pas}" ]]; then
        echo_content red "Password cannot be empty."
      else
        break
      fi
    done

    docker exec trojan-panel-mariadb mysql -h"${mariadb_ip}" -P"${mariadb_port}" -u"${mariadb_user}" -p"${mariadb_pas}" -e "create database if not exists trojan_panel_db;" &>/dev/null

    read -r -p "Please enter the IP address of your Redis server (default: local Redis): " redis_host
    [[ -z "${redis_host}" ]] && redis_host="127.0.0.1"
    read -r -p "Please enter the port of your Redis server (default: 6378): " redis_port
    [[ -z "${redis_port}" ]] && redis_port=6378
    while read -r -p "Please enter the password of your Redis server (required): " redis_pass; do
      if [[ -z "${redis_pass}" ]]; then
        echo_content red "Password cannot be empty."
      else
        break
      fi
    done

    docker exec trojan-panel-redis redis-cli -h "${redis_host}" -p "${redis_port}" -a "${redis_pass}" -e "flushall" &>/dev/null

    docker pull jonssonyan/trojan-panel &&
      docker run -d --name trojan-panel --restart always \
        --network=host \
        -v ${WEB_PATH}:${TROJAN_PANEL_WEBFILE} \
        -v ${TROJAN_PANEL_LOGS}:${TROJAN_PANEL_LOGS} \
        -v ${TROJAN_PANEL_CONFIG}:${TROJAN_PANEL_CONFIG} \
        -v /etc/localtime:/etc/localtime \
        -e GIN_MODE=release \
        -e "mariadb_ip=${mariadb_ip}" \
        -e "mariadb_port=${mariadb_port}" \
        -e "mariadb_user=${mariadb_user}" \
        -e "mariadb_pas=${mariadb_pas}" \
        -e "redis_host=${redis_host}" \
        -e "redis_port=${redis_port}" \
        -e "redis_pass=${redis_pass}" \
        -e "server_port=${trojan_panel_port}" \
        jonssonyan/trojan-panel

    if [[ -n $(docker ps -q -f "name=^trojan-panel$" -f "status=running") ]]; then
      echo_content skyBlue "---> Trojan Panel backend has been installed."

      echo_content red "\n=============================================================="
      echo_content skyBlue "Trojan Panel backend has been installed successfully."
      echo_content yellow "MariaDB ${mariadb_user}'s password (please keep it safe): ${mariadb_pas}"
      echo_content yellow "Redis' password (please keep it safe): ${redis_pass}"
      echo_content white "System administrator default username: ¤ sysadmin ¤ & default password: ¤ 123456 ¤ , Please log in to the management panel and change the password as soon as possible."
      echo_content yellow "Trojan Panel private key and certificate directory: ${CERT_PATH}"
      echo_content red "\n=============================================================="
    else
      echo_content red "---> Failed to install Trojan Panel backend or it is not running properly. Please try to fix it or reinstall."
      exit 0
    fi
  else
    echo_content skyBlue "---> You have already installed Trojan Panel backend."
  fi
}

# Install Trojan Panel core
install_trojan_panel_core() {
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-core$") ]]; then
    echo_content green "---> Installing Trojan Panel core."

    read -r -p "Please enter the service port for Trojan Panel core (default: 8082): " trojan_panel_core_port
    [[ -z "${trojan_panel_core_port}" ]] && trojan_panel_core_port=8082
    
    read -r -p "Please enter the IP address of your MariaDB database (default: local database): " mariadb_ip
    [[ -z "${mariadb_ip}" ]] && mariadb_ip="127.0.0.1"
    read -r -p "Please enter the port of your MariaDB database (default: 9507): " mariadb_port
    [[ -z "${mariadb_port}" ]] && mariadb_port=9507
    read -r -p "Please enter the username of your MariaDB database (default: root): " mariadb_user
    [[ -z "${mariadb_user}" ]] && mariadb_user="root"
    while read -r -p "Please enter the password of your MariaDB database (required): " mariadb_pas; do
      if [[ -z "${mariadb_pas}" ]]; then
        echo_content red "Password cannot be empty."
      else
        break
      fi
    done
    read -r -p "Please enter the name of your database (default: trojan_panel_db): " database
    [[ -z "${database}" ]] && database="trojan_panel_db"
    read -r -p "Please enter the name of the user table in your database (default: account): " account_table
    [[ -z "${account_table}" ]] && account_table="account"

    read -r -p "Please enter the IP address of your Redis server (default: local Redis): " redis_host
    [[ -z "${redis_host}" ]] && redis_host="127.0.0.1"
    read -r -p "Please enter the port of your Redis server (default: 6378): " redis_port
    [[ -z "${redis_port}" ]] && redis_port=6378
    while read -r -p "Please enter the password of your Redis server (required): " redis_pass; do
      if [[ -z "${redis_pass}" ]]; then
        echo_content red "Password cannot be empty."
      else
        break
      fi
    done
    read -r -p "Please enter the API port (default: 8100): " grpc_port 
    [[ -z "${grpc_port}" ]] && grpc_port=8100

    domain=$(cat "${DOMAIN_FILE}")

    docker pull jonssonyan/trojan-panel-core &&
      docker run -d --name trojan-panel-core --restart always \
        --network=host \
        -v ${TROJAN_PANEL_CORE_DATA}bin/xray/config:${TROJAN_PANEL_CORE_DATA}bin/xray/config \
        -v ${TROJAN_PANEL_CORE_DATA}bin/trojango/config:${TROJAN_PANEL_CORE_DATA}bin/trojango/config \
        -v ${TROJAN_PANEL_CORE_DATA}bin/hysteria/config:${TROJAN_PANEL_CORE_DATA}bin/hysteria/config \
        -v ${TROJAN_PANEL_CORE_DATA}bin/naiveproxy/config:${TROJAN_PANEL_CORE_DATA}bin/naiveproxy/config \
        -v ${TROJAN_PANEL_CORE_LOGS}:${TROJAN_PANEL_CORE_LOGS} \
        -v ${TROJAN_PANEL_CORE_CONFIG}:${TROJAN_PANEL_CORE_CONFIG} \
        -v ${CERT_PATH}:${CERT_PATH} \
        -v ${WEB_PATH}:${WEB_PATH} \
        -v /etc/localtime:/etc/localtime \
        -e GIN_MODE=release \
        -e "mariadb_ip=${mariadb_ip}" \
        -e "mariadb_port=${mariadb_port}" \
        -e "mariadb_user=${mariadb_user}" \
        -e "mariadb_pas=${mariadb_pas}" \
        -e "database=${database}" \
        -e "account-table=${account_table}" \
        -e "redis_host=${redis_host}" \
        -e "redis_port=${redis_port}" \
        -e "redis_pass=${redis_pass}" \
        -e "crt_path=${CERT_PATH}${domain}.crt" \
        -e "key_path=${CERT_PATH}${domain}.key" \
        -e "grpc_port=${grpc_port}" \
        -e "server_port=${trojan_panel_core_port}" \
        jonssonyan/trojan-panel-core
    if [[ -n $(docker ps -q -f "name=^trojan-panel-core$" -f "status=running") ]]; then
      echo_content skyBlue "---> Trojan Panel core has been installed."
    else
      echo_content red "---> Failed to install Trojan Panel core or it is not running properly. Please try to fix it or reinstall."
      exit 0
    fi
  else
    echo_content skyBlue "---> You have already installed Trojan Panel core." 
  fi
}

# Update Trojan Panel data structure
update__trojan_panel_database() {
  echo_content skyBlue "---> Updating Trojan Panel data structure." 

  if [[ "${trojan_panel_current_version}" == "v1.3.1" ]]; then
    docker exec trojan-panel-mariadb mysql -h"${mariadb_ip}" -P"${mariadb_port}" -u"${mariadb_user}" -p"${mariadb_pas}" -Dtrojan_panel_db -e "${sql_200}" &>/dev/null &&
      trojan_panel_current_version="v2.0.0"
  fi
  version_200_203=("v2.0.0" "v2.0.1" "v2.0.2")
  if [[ "${version_200_203[*]}" =~ "${trojan_panel_current_version}" ]]; then
    docker exec trojan-panel-mariadb mysql -h"${mariadb_ip}" -P"${mariadb_port}" -u"${mariadb_user}" -p"${mariadb_pas}" -Dtrojan_panel_db -e "${sql_203}" &>/dev/null &&
      trojan_panel_current_version="v2.0.3"
  fi
  version_203_205=("v2.0.3" "v2.0.4")
  if [[ "${version_203_205[*]}" =~ "${trojan_panel_current_version}" ]]; then
    docker exec trojan-panel-mariadb mysql -h"${mariadb_ip}" -P"${mariadb_port}" -u"${mariadb_user}" -p"${mariadb_pas}" -Dtrojan_panel_db -e "${sql_205}" &>/dev/null &&
      trojan_panel_current_version="v2.0.5"
  fi
  version_205_210=("v2.0.5")
  if [[ "${version_205_210[*]}" =~ "${trojan_panel_current_version}" ]]; then
    domain=$(cat "${DOMAIN_FILE}")
    if [[ -z "${domain}" ]]; then
      docker rm -f trojan-panel-caddy
      rm -rf /tpdata/caddy/srv/
      rm -rf /tpdata/caddy/cert/
      rm -f /tpdata/caddy/domain.lock
      install_reverse_proxy
      cp /tpdata/nginx/default.conf ${UI_NGINX_CONFIG} &&
        sed -i "s#/tpdata/caddy/cert/#${CERT_PATH}#g" ${UI_NGINX_CONFIG}
    fi
    docker exec trojan-panel-mariadb mysql -h"${mariadb_ip}" -P"${mariadb_port}" -u"${mariadb_user}" -p"${mariadb_pas}" -Dtrojan_panel_db -e "${sql_210}" &>/dev/null &&
      trojan_panel_current_version="v2.1.0"
  fi
  version_210_211=("v2.1.0")
  if [[ "${version_210_211[*]}" =~ "${trojan_panel_current_version}" ]]; then
    docker exec trojan-panel-mariadb mysql -h"${mariadb_ip}" -P"${mariadb_port}" -u"${mariadb_user}" -p"${mariadb_pas}" -Dtrojan_panel_db -e "${sql_211}" &>/dev/null &&
      trojan_panel_current_version="v2.1.1"
  fi
  version_211_212=("v2.1.1")
  if [[ "${version_211_212[*]}" =~ "${trojan_panel_current_version}" ]]; then
    docker exec trojan-panel-mariadb mysql -h"${mariadb_ip}" -P"${mariadb_port}" -u"${mariadb_user}" -p"${mariadb_pas}" -Dtrojan_panel_db -e "${sql_212}" &>/dev/null &&
      trojan_panel_current_version="v2.1.2"
  fi
  version_212_214=("v2.1.2" "v2.1.3")
  if [[ "${version_212_214[*]}" =~ "${trojan_panel_current_version}" ]]; then
    docker cp trojan-panel:${trojan_panel_config_path} ${trojan_panel_config_path} &&
      trojan_panel_current_version="v2.1.4" &&
      echo '[server]
port=8081'>>${trojan_panel_config_path}

    docker rm -f trojan-panel-ui &&
      docker rmi -f jonssonyan/trojan-panel-ui

    docker pull jonssonyan/trojan-panel-ui &&
      docker run -d --name trojan-panel-ui --restart always \
        --network=host \
        -v "${UI_NGINX_CONFIG}":"/etc/nginx/conf.d/default.conf" \
        -v ${CERT_PATH}:${CERT_PATH} \
        jonssonyan/trojan-panel-ui

    if [[ -n $(docker ps -q -f "name=^trojan-panel-ui$" -f "status=running") ]]; then
      echo_content skyBlue "---> Trojan Panel UI has been updated."
    else
      echo_content red "---> Failed to update Trojan Panel UI or it is not running properly. Please try to fix it or reinstall."
    fi
  fi

  echo_content skyBlue "---> Trojan Panel data structure has been updated."
}

# Update Trojan Panel core data structure
update__trojan_panel_core_database() {
  echo_content skyBlue "---> Updating Trojan Panel core data structure."

  version_204_210=("v2.0.4")
  if [[ "${version_204_210[*]}" =~ "${trojan_panel_core_current_version}" ]]; then
    domain=$(cat "${DOMAIN_FILE}")
    if [[ -z "${domain}" ]]; then
      docker rm -f trojan-panel-caddy
      rm -rf /tpdata/caddy/srv/
      rm -rf /tpdata/caddy/cert/
      rm -f /tpdata/caddy/domain.lock
      install_reverse_proxy
      cp /tpdata/nginx/default.conf ${UI_NGINX_CONFIG} &&
        sed -i "s#/tpdata/caddy/cert/#${CERT_PATH}#g" ${UI_NGINX_CONFIG}
    fi
    trojan_panel_core_current_version="v2.1.0"
  fi
  version_210_211=("v2.1.0")
  if [[ "${version_210_211[*]}" =~ "${trojan_panel_core_current_version}" ]]; then
    docker cp trojan-panel-core:${trojan_panel_core_config_path} ${trojan_panel_core_config_path} &&
      trojan_panel_core_current_version="v2.1.1" &&
      echo '[server]
port=8082'>>${trojan_panel_core_config_path}
  fi

  echo_content skyBlue "---> Trojan Panel core data structure has been updated."
}

# Update Trojan Panel UI
update_trojan_panel_ui() {
  # Check if Trojan Panel UI is installed
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-ui$") ]]; then
    echo_content red "---> Please install Trojan Panel UI first."
    exit 0
  fi

  trojan_panel_ui_current_version=$(docker exec trojan-panel-ui cat ${TROJAN_PANEL_UI_DATA}version)
  if [[ -z "${trojan_panel_ui_current_version}" || ! "${trojan_panel_ui_current_version}" =~ ^v.* ]]; then
    echo_content red "---> The current version does not support automated updates."
    exit 0
  fi

  echo_content yellow "Note: The current version of Trojan Panel UI (trojan-panel-ui) is ${trojan_panel_ui_current_version}, while the latest version is ${trojan_panel_ui_latest_version}."

  if [[ "${trojan_panel_ui_current_version}" != "${trojan_panel_ui_latest_version}" ]]; then
    echo_content green "---> Updating Trojan Panel UI." 

    docker rm -f trojan-panel-ui &&
      docker rmi -f jonssonyan/trojan-panel-ui

    docker pull jonssonyan/trojan-panel-ui &&
      docker run -d --name trojan-panel-ui --restart always \
        --network=host \
        -v "${UI_NGINX_CONFIG}":"/etc/nginx/conf.d/default.conf" \
        -v ${CERT_PATH}:${CERT_PATH} \
        jonssonyan/trojan-panel-ui

    if [[ -n $(docker ps -q -f "name=^trojan-panel-ui$" -f "status=running") ]]; then
      echo_content skyBlue "---> Trojan Panel front-end update completed"
    else
      echo_content red "---> Trojan Panel front-end update failed or running abnormally, please try to repair or uninstall and reinstall"
    fi
  else
    echo_content skyBlue "---> The Trojan Panel front end you installed is already the latest version"
  fi
}

# Update Trojan Panel backend
update_trojan_panel() {
  # Check if Trojan Panel backend is installed
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel$") ]]; then
    echo_content red "---> Please install Trojan Panel backend first."
    exit 0
  fi

  trojan_panel_current_version=$(docker exec trojan-panel ./trojan-panel -version)
  if [[ -z "${trojan_panel_current_version}" || ! "${trojan_panel_current_version}" =~ ^v.* ]]; then
    echo_content red "---> The current version does not support automated updates."
    exit 0
  fi

  echo_content yellow "Note: The current version of Trojan Panel backend (trojan-panel) is ${trojan_panel_current_version}, while the latest version is ${trojan_panel_latest_version}."

  if [[ "${trojan_panel_current_version}" != "${trojan_panel_latest_version}" ]]; then
    echo_content green "---> Updating Trojan Panel backend." 

    update__trojan_panel_database

    mariadb_ip=$(get_ini_value ${trojan_panel_config_path} mysql.host)
    mariadb_port=$(get_ini_value ${trojan_panel_config_path} mysql.port)
    mariadb_user=$(get_ini_value ${trojan_panel_config_path} mysql.user)
    mariadb_pas=$(get_ini_value ${trojan_panel_config_path} mysql.password)
    redis_host=$(get_ini_value ${trojan_panel_config_path} redis.host)
    redis_port=$(get_ini_value ${trojan_panel_config_path} redis.port)
    redis_pass=$(get_ini_value ${trojan_panel_config_path} redis.password)
    trojan_panel_port=$(get_ini_value ${trojan_panel_config_path} server.port)

    docker exec trojan-panel-redis redis-cli -h "${redis_host}" -p "${redis_port}" -a "${redis_pass}" -e "flushall" &>/dev/null

    docker rm -f trojan-panel &&
      docker rmi -f jonssonyan/trojan-panel

    docker pull jonssonyan/trojan-panel &&
      docker run -d --name trojan-panel --restart always \
        --network=host \
        -v ${WEB_PATH}:${TROJAN_PANEL_WEBFILE} \
        -v ${TROJAN_PANEL_LOGS}:${TROJAN_PANEL_LOGS} \
        -v ${TROJAN_PANEL_CONFIG}:${TROJAN_PANEL_CONFIG} \
        -v /etc/localtime:/etc/localtime \
        -e GIN_MODE=release \
        -e "mariadb_ip=${mariadb_ip}" \
        -e "mariadb_port=${mariadb_port}" \
        -e "mariadb_user=${mariadb_user}" \
        -e "mariadb_pas=${mariadb_pas}" \
        -e "redis_host=${redis_host}" \
        -e "redis_port=${redis_port}" \
        -e "redis_pass=${redis_pass}" \
        -e "server_port=${trojan_panel_port}" \
        jonssonyan/trojan-panel

    if [[ -n $(docker ps -q -f "name=^trojan-panel$" -f "status=running") ]]; then
      echo_content skyBlue "---> Trojan Panel backend update complete"
    else
      echo_content red "---> Failed to update Trojan Panel backend or it is not running properly. Please try to fix it or reinstall."
    fi
  else
    echo_content skyBlue "---> The Trojan Panel backend you installed is already up-to-date."
  fi
}

# Update Trojan Panel Core
update_trojan_panel_core() {
  # Check if Trojan Panel Core is installed
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-core$") ]]; then
    echo_content red "---> Please install Trojan Panel Core first."
    exit 0
  fi

  trojan_panel_core_current_version=$(docker exec trojan-panel-core ./trojan-panel-core -version)
  if [[ -z "${trojan_panel_core_current_version}" || ! "${trojan_panel_core_current_version}" =~ ^v.* ]]; then
    echo_content red "---> The current version does not support automated updates."
    exit 0
  fi

  echo_content yellow "Note: The current version of Trojan Panel Core (trojan-panel-core) is ${trojan_panel_core_current_version}, while the latest version is ${trojan_panel_core_latest_version}."

  if [[ "${trojan_panel_core_current_version}" != "${trojan_panel_core_latest_version}" ]]; then
    echo_content green "---> Updating Trojan Panel Core."

    update__trojan_panel_core_database

    mariadb_ip=$(get_ini_value ${trojan_panel_core_config_path} mysql.host)
    mariadb_port=$(get_ini_value ${trojan_panel_core_config_path} mysql.port)
    mariadb_user=$(get_ini_value ${trojan_panel_core_config_path} mysql.user)
    mariadb_pas=$(get_ini_value ${trojan_panel_core_config_path} mysql.password)
    redis_host=$(get_ini_value ${trojan_panel_core_config_path} redis.host)
    redis_port=$(get_ini_value ${trojan_panel_core_config_path} redis.port)
    redis_pass=$(get_ini_value ${trojan_panel_core_config_path} redis.password)
    grpc_port=$(get_ini_value ${trojan_panel_core_config_path} grpc.port)
    trojan_panel_core_port=$(get_ini_value ${trojan_panel_core_config_path} server.port)

    docker exec trojan-panel-redis redis-cli -h "${redis_host}" -p "${redis_port}" -a "${redis_pass}" -e "flushall" &>/dev/null

    docker rm -f trojan-panel-core &&
      docker rmi -f jonssonyan/trojan-panel-core

    domain=$(cat "${DOMAIN_FILE}")

    docker pull jonssonyan/trojan-panel-core &&
      docker run -d --name trojan-panel-core --restart always \
        --network=host \
        -v ${TROJAN_PANEL_CORE_DATA}bin/xray/config:${TROJAN_PANEL_CORE_DATA}bin/xray/config \
        -v ${TROJAN_PANEL_CORE_DATA}bin/trojango/config:${TROJAN_PANEL_CORE_DATA}bin/trojango/config \
        -v ${TROJAN_PANEL_CORE_DATA}bin/hysteria/config:${TROJAN_PANEL_CORE_DATA}bin/hysteria/config \
        -v ${TROJAN_PANEL_CORE_DATA}bin/naiveproxy/config:${TROJAN_PANEL_CORE_DATA}bin/naiveproxy/config \
        -v ${TROJAN_PANEL_CORE_LOGS}:${TROJAN_PANEL_CORE_LOGS} \
        -v ${TROJAN_PANEL_CORE_CONFIG}:${TROJAN_PANEL_CORE_CONFIG} \
        -v ${CERT_PATH}:${CERT_PATH} \
        -v ${WEB_PATH}:${WEB_PATH} \
        -v /etc/localtime:/etc/localtime \
        -e GIN_MODE=release \
        -e "mariadb_ip=${mariadb_ip}" \
        -e "mariadb_port=${mariadb_port}" \
        -e "mariadb_user=${mariadb_user}" \
        -e "mariadb_pas=${mariadb_pas}" \
        -e "database=${database}" \
        -e "account-table=${account_table}" \
        -e "redis_host=${redis_host}" \
        -e "redis_port=${redis_port}" \
        -e "redis_pass=${redis_pass}" \
        -e "crt_path=${CERT_PATH}${domain}.crt" \
        -e "key_path=${CERT_PATH}${domain}.key" \
        -e "grpc_port=${grpc_port}" \
        -e "server_port=${trojan_panel_core_port}" \
        jonssonyan/trojan-panel-core

    if [[ -n $(docker ps -q -f "name=^trojan-panel-core$" -f "status=running") ]]; then
      echo_content skyBlue "---> Trojan Panel Core has been updated."
    else
      echo_content red "---> Failed to update Trojan Panel Core or it is not running properly. Please try to fix it or reinstall."
    fi
  else
    echo_content skyBlue "---> The Trojan Panel Core you installed is already up-to-date."
  fi
}

# Uninstall Caddy2
uninstall_caddy2() {
  # Check if Caddy2 is installed
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-caddy$") ]]; then
    echo_content green "---> Uninstalling Caddy2."

    docker rm -f trojan-panel-caddy &&
      rm -rf ${CADDY_DATA}

    echo_content skyBlue "---> Caddy2 has been uninstalled."
  else
    echo_content red "---> Please install Caddy2 first."
  fi
}

# Uninstall Nginx
uninstall_nginx() {
  # Check if Nginx is installed
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-nginx") ]]; then
    echo_content green "---> Uninstalling Nginx."

    docker rm -f trojan-panel-nginx &&
      rm -rf ${NGINX_DATA}

    echo_content skyBlue "---> Nginx has been uninstalled."
  else
    echo_content red "---> Please install Nginx first."
  fi
}

# Uninstall MariaDB
uninstall_mariadb() {
  # Check if MariaDB is installed
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-mariadb$") ]]; then
    echo_content green "---> Uninstalling MariaDB."

    docker rm -f trojan-panel-mariadb &&
      rm -rf ${MARIA_DATA}

    echo_content skyBlue "---> MariaDB has been uninstalled."
  else
    echo_content red "---> Please install MariaDB first."
  fi
}

# Uninstall Redis
uninstall_redis() {
  # Check if Redis is installed
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-redis$") ]]; then
    echo_content green "---> Uninstalling Redis."

    docker rm -f trojan-panel-redis &&
      rm -rf ${REDIS_DATA}

    echo_content skyBlue "---> Redis has been uninstalled."
  else
    echo_content red "---> Please install Redis first."
  fi
}

# Uninstall Trojan Panel frontend
uninstall_trojan_panel_ui() {
  # Check if Trojan Panel frontend is installed
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-ui$") ]]; then
    echo_content green "---> Uninstalling Trojan Panel frontend."

    docker rm -f trojan-panel-ui &&
      docker rmi -f jonssonyan/trojan-panel-ui &&
      rm -rf ${TROJAN_PANEL_UI_DATA}

    echo_content skyBlue "---> Trojan Panel frontend has been uninstalled."
  else
    echo_content red "---> Please install Trojan Panel frontend first."
  fi
}

# Uninstall Trojan Panel backend
uninstall_trojan_panel() {
  # Check if Trojan Panel backend is installed
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel$") ]]; then
    echo_content green "---> Uninstalling Trojan Panel backend."

    docker rm -f trojan-panel &&
      docker rmi -f jonssonyan/trojan-panel &&
      rm -rf ${TROJAN_PANEL_DATA}

    echo_content skyBlue "---> Trojan Panel backend has been uninstalled."
  else
    echo_content red "---> Please install Trojan Panel backend first."
  fi
}

# Uninstall Trojan Panel Core
uninstall_trojan_panel_core() {
  # Check if Trojan Panel Core is installed
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-core$") ]]; then
    echo_content green "---> Uninstalling Trojan Panel Core."

    docker rm -f trojan-panel-core &&
      docker rmi -f jonssonyan/trojan-panel-core &&
      rm -rf ${TROJAN_PANEL_CORE_DATA}

    echo_content skyBlue "---> Trojan Panel Core has been uninstalled."
  else
    echo_content red "---> Please install Trojan Panel Core first."
  fi
}

# Uninstall all Trojan Panel-related containers
uninstall_all() {
  echo_content green "---> Uninstalling all Trojan Panel-related containers."

  docker rm -f $(docker ps -a -q -f "name=^trojan-panel")
  docker rmi -f $(docker images | grep "^jonssonyan/trojan-panel" | awk '{print $3}')
  rm -rf ${TP_DATA}

  echo_content skyBlue "---> All Trojan Panel-related containers have been uninstalled."
}

# Update Trojan Panel frontend port
update_trojan_panel_ui_port() {
  if [[ -n $(docker ps -q -f "name=^trojan-panel-ui$" -f "status=running") ]]; then
    echo_content green "---> Updating Trojan Panel frontend port."

    trojan_panel_ui_port=$(grep 'listen.*ssl' ${UI_NGINX_CONFIG} | awk '{print $2}')
    if [[ -z "${trojan_panel_ui_port}" ]]; then
      ui_https=0
      trojan_panel_ui_port=$(grep -oP 'listen\s+\K\d+' ${UI_NGINX_CONFIG} | awk 'NR==1')
    fi
    if [[ -z "${trojan_panel_ui_port}" ]]; then
      echo_content red "---> Failed to find the port for Trojan Panel frontend."
      exit 0
    fi
    echo_content yellow "Note: The current port for Trojan Panel frontend (trojan-panel-ui) is ${trojan_panel_ui_port}."

    read -r -p "Please enter a new port number for Trojan Panel frontend (default: 2083): " trojan_panel_ui_port
    [[ -z "${trojan_panel_ui_port}" ]] && trojan_panel_ui_port="2083"

    if [[ ${ui_https} == 0 ]]; then
      # http
      sed -i "s/listen.*;/listen       ${trojan_panel_ui_port};/g" ${UI_NGINX_CONFIG} &&
        sed -i "s/http:\/\/\$host:.*\$request_uri;/http:\/\/\$host:${trojan_panel_ui_port}\$request_uri;/g" ${UI_NGINX_CONFIG} &&
        docker restart trojan-panel-ui
    else
      # https
      sed -i "s/listen.*ssl;/listen       ${trojan_panel_ui_port} ssl;/g" ${UI_NGINX_CONFIG} &&
        sed -i "s/https:\/\/\$host:.*\$request_uri;/https:\/\/\$host:${trojan_panel_ui_port}\$request_uri;/g" ${UI_NGINX_CONFIG} &&
        docker restart trojan-panel-ui
    fi

    if [[ "$?" == "0" ]]; then
      echo_content skyBlue "---> Trojan Panel frontend port has been updated."
    else
      echo_content red "---> Failed to update Trojan Panel frontend port."
    fi
  else
    echo_content red "---> Trojan Panel frontend is not installed or failed to run. Please fix it or reinstall and try again."
  fi
}

# Refresh Redis cache
redis_flush_all() {
  # Check if Redis is installed
  if [[ -z $(docker ps -a -q -f "name=^trojan-panel-redis$") ]]; then
    echo_content red "---> Please install Redis first."
    exit 0
  fi

  if [[ -z $(docker ps -q -f "name=^trojan-panel-redis$" -f "status=running") ]]; then
    echo_content red "---> Redis failed to run."
    exit 0
  fi

  echo_content green "---> Refreshing Redis cache."

  read -r -p "Please enter the IP address of Redis (default: local Redis): " redis_host
  [[ -z "${redis_host}" ]] && redis_host="127.0.0.1"
  read -r -p "Please enter the port number of Redis (default: 6378): " redis_port
  [[ -z "${redis_port}" ]] && redis_port=6378
  while read -r -p "Please enter the password for Redis (required): " redis_pass; do
    if [[ -z "${redis_pass}" ]]; then
      echo_content red "Password cannot be empty."
    else
      break
    fi
  done

  docker exec trojan-panel-redis redis-cli -h "${redis_host}" -p "${redis_port}" -a "${redis_pass}" -e "flushall" &>/dev/null

  echo_content skyBlue "---> Redis cache has been refreshed."
}

# 更换证书
change_cert() {
  domain_1=$(cat "${DOMAIN_FILE}")

  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-caddy$") ]]; then
    docker rm -f trojan-panel-caddy &&
      rm -rf ${CADDY_LOG}* &&
      echo "" >${CADDY_CONFIG} &&
      rm -rf ${WEB_PATH}*
  fi

  rm -rf ${CERT_PATH}* &&
    echo "" >${DOMAIN_FILE}

  install_cert

  domain_2=$(cat "${DOMAIN_FILE}")
  if [[ -n "${domain_1}" && -n "${domain_2}" ]]; then
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel-nginx$") ]]; then
      sed -i "s/${domain_1}/${domain_2}/g" ${NGINX_CONFIG} &&
        docker restart trojan-panel-nginx
    fi
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel-ui$") ]]; then
      sed -i "s/${domain_1}/${domain_2}/g" ${UI_NGINX_DATA} &&
        docker restart trojan-panel-ui
    fi
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel-core$") ]]; then
      find /tpdata/trojan-panel-core/bin/ -type f -exec sed -i "s/${domain_1}/${domain_2}/g" {} + &&
        sed -i "s/${domain_1}/${domain_2}/g" ${trojan_panel_core_config_path} &&
        docker restart trojan-panel-core
    fi
  fi
}

# Failure testing
failure_testing() {
  echo_content green "---> Starting failure testing"
  if [[ ! $(docker -v 2>/dev/null) ]]; then
    echo_content red "---> Docker failed to run."
  else
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel-caddy$") ]]; then
      if [[ -z $(docker ps -q -f "name=^trojan-panel-caddy$" -f "status=running") ]]; then
        echo_content red "---> Caddy2 failed to run. The error log is as follows:"
        docker logs trojan-panel-caddy
      fi
      domain=$(cat "${DOMAIN_FILE}")
      if [[ -z ${domain} || ! -d "${CERT_PATH}" || ! -f "${CERT_PATH}${domain}.crt" ]]; then
        echo_content red "---> Certificate application failed. Please try one of the following options: 1. Use a different subdomain to rebuild it. 2. Restart the server to reapply for the certificate. 3. When rebuilding, choose the option for custom certificates. The log is as follows:"
        if [[ -f ${CADDY_LOG}error.log ]]; then
          tail -n 20 ${CADDY_LOG}error.log | grep error
        else
          docker logs trojan-panel-caddy
        fi
      fi
    fi
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel-mariadb$") && -z $(docker ps -q -f "name=^trojan-panel-mariadb$" -f "status=running") ]]; then
      echo_content red "---> MariaDB failed to run. The log is as follows:"
      docker logs trojan-panel-mariadb
    fi
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel-redis$") && -z $(docker ps -q -f "name=^trojan-panel-redis$" -f "status=running") ]]; then
      echo_content red "---> Redis failed to run. The log is as follows:"
      docker logs trojan-panel-redis
    fi
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel$") && -z $(docker ps -q -f "name=^trojan-panel$" -f "status=running") ]]; then
      echo_content red "---> Trojan Panel backend failed to run. The log is as follows:"
      if [[ -f ${TROJAN_PANEL_LOGS}trojan-panel.log ]]; then
        tail -n 20 ${TROJAN_PANEL_LOGS}trojan-panel.log | grep error
      else
        docker logs trojan-panel
      fi
    fi
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel-ui$") && -z $(docker ps -q -f "name=^trojan-panel-ui$" -f "status=running") ]]; then
      echo_content red "---> Trojan Panel frontend failed to run. The log is as follows:"
      docker logs trojan-panel-ui
    fi
    if [[ -n $(docker ps -a -q -f "name=^trojan-panel-core$") && -z $(docker ps -q -f "name=^trojan-panel-core$" -f "status=running") ]]; then
      echo_content red "---> Trojan Panel Core failed to run. The log is as follows:"
      if [[ -f ${TROJAN_PANEL_CORE_LOGS}trojan-panel.log ]]; then
        tail -n 20 ${TROJAN_PANEL_CORE_LOGS}trojan-panel.log | grep error
      else
        docker logs trojan-panel-core
      fi
    fi
  fi
  echo_content green "---> End of troubleshooting."
}

log_query() {
  while :; do
    echo_content skyBlue "The following applications can be queried for logs:"
    echo_content yellow "1. Trojan Panel backend"
    echo_content yellow "2. Trojan Panel Core"
    echo_content yellow "3. Exit"
    read -r -p "Please select an application (default: 1): " select_log_query_type
    [[ -z "${select_log_query_type}" ]] && select_log_query_type=1    

    case ${select_log_query_type} in
    1)
      log_file_path=${TROJAN_PANEL_LOGS}trojan-panel.log
      ;;
    2)
      log_file_path=${TROJAN_PANEL_CORE_LOGS}trojan-panel-core.log
      ;;
    3)
      break
      ;;
    *)
      echo_content red "Option not available."
      continue
      ;;
    esac

    read -r -p "Please enter the number of lines to query (default: 20): " select_log_query_line_type
    [[ -z "${select_log_query_line_type}" ]] && select_log_query_line_type=20

    if [[ -f ${log_file_path} ]]; then
      echo_content skyBlue "The log is as follows:"
      tail -n ${select_log_query_line_type} ${log_file_path}
    else
      echo_content red "Log file does not exist."
    fi
  done
}

version_query() {
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-ui$") && -n $(docker ps -q -f "name=^trojan-panel-ui$" -f "status=running") ]]; then
    trojan_panel_ui_current_version=$(docker exec trojan-panel-ui cat ${TROJAN_PANEL_UI_DATA}version)
    echo_content yellow "The current version of Trojan Panel frontend (trojan-panel-ui) is ${trojan_panel_ui_current_version}, and the latest version is ${trojan_panel_ui_latest_version}."
  fi
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel$") && -n $(docker ps -q -f "name=^trojan-panel$" -f "status=running") ]]; then
    trojan_panel_current_version=$(docker exec trojan-panel ./trojan-panel -version)
    echo_content yellow "The current version of Trojan Panel backend (trojan-panel) is ${trojan_panel_current_version}, and the latest version is ${trojan_panel_latest_version}."
  fi
  if [[ -n $(docker ps -a -q -f "name=^trojan-panel-core$") && -n $(docker ps -q -f "name=^trojan-panel-core$" -f "status=running") ]]; then
    trojan_panel_core_current_version=$(docker exec trojan-panel-core ./trojan-panel-core -version)
    echo_content yellow "The current version of Trojan Panel Core (trojan-panel-core) is ${trojan_panel_core_current_version}, and the latest version is ${trojan_panel_core_latest_version}."
  fi
}

main() {
  cd "$HOME" || exit 0
  init_var
  mkdir_tools
  check_sys
  depend_install
  clear
  echo_content red "\n *                Welcome To Trojan                  *"
echo_content skyBlue "System Required: CentOS 7+/Ubuntu 18+/Debian 10+"
echo_content skyBlue "Version: v2.2.1"
echo_content skyBlue "Description: One click Install Trojan Panel server"
echo_content skyBlue "Author: sedaghatpour <https://sedaghatpour.com>"
echo_content skyBlue "Github: https://github.com/sedaghatpour"
echo_content skyBlue "Docs: https://trojanpanel.github.io"
echo_content white "\n=============================================================="
echo_content green "1. Install Trojan Panel Frontend"
echo_content green "2. Install Trojan Panel Backend"
echo_content green "3. Install Trojan Panel Core"
echo_content yellow "4. Install Caddy2"
echo_content yellow "5. Install Nginx"
echo_content yellow "6. Install MariaDB"
echo_content yellow "7. Install Redis"
echo_content white "\n=============================================================="
echo_content yellow "8. Update Trojan Panel Frontend"
echo_content yellow "9. Update Trojan Panel Backend"
echo_content yellow "10. Update Trojan Panel Core"
echo_content white "\n=============================================================="
echo_content yellow "11. Uninstall Trojan Panel Frontend"
echo_content yellow "12. Uninstall Trojan Panel Backend"
echo_content yellow "13. Uninstall Trojan Panel Core"
echo_content yellow "14. Uninstall Caddy2"
echo_content yellow "15. Uninstall Nginx"
echo_content yellow "16. Uninstall MariaDB"
echo_content yellow "17. Uninstall Redis"
echo_content yellow "18. Uninstall all Trojan Panel related applications"
echo_content white "\n=============================================================="
echo_content yellow "19. Modify Trojan Panel Frontend Port"
echo_content yellow "20. Refresh Redis Cache"
echo_content yellow "21. Replace certificate"
echo_content red "\n============https://t.me/P_tech2024============================================"
echo_content yellow "22. Fault Detection"
echo_content yellow "23. Log Query"
echo_content yellow "24. Version Query"
read -r -p "Please select an option:" selectInstall_type
  case ${selectInstall_type} in
  1)
    install_docker
    install_cert
    install_trojan_panel_ui
    ;;
  2)
    install_docker
    install_mariadb
    install_redis
    install_trojan_panel
    ;;
  3)
    install_docker
    install_reverse_proxy
    install_cert
    install_trojan_panel_core
    ;;
  4)
    install_docker
    install_caddy2
    ;;
  5)
    install_docker
    install_nginx
    ;;
  6)
    install_docker
    install_mariadb
    ;;
  7)
    install_docker
    install_redis
    ;;
  8)
    update_trojan_panel_ui
    ;;
  9)
    update_trojan_panel
    ;;
  10)
    update_trojan_panel_core
    ;;
  11)
    uninstall_trojan_panel_ui
    ;;
  12)
    uninstall_trojan_panel
    ;;
  13)
    uninstall_trojan_panel_core
    ;;
  14)
    uninstall_caddy2
    ;;
  15)
    uninstall_nginx
    ;;
  16)
    uninstall_mariadb
    ;;
  17)
    uninstall_redis
    ;;
  18)
    uninstall_all
    ;;
  19)
    update_trojan_panel_ui_port
    ;;
  20)
    redis_flush_all
    ;;
  21)
    change_cert
    ;;
  22)
    failure_testing
    ;;
  23)
    log_query
    ;;
  24)
    version_query
    ;;
  *)
    echo_content red "No such option"
    ;;
  esac
}

main
