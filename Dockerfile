ARG release=latest

FROM ubuntu:${release}

ARG zabbix_version=4.2

ARG db_name=zabbix
ARG mysql_user=zabbix
ARG mysql_password=
ARG mysql_host=localhost

COPY database/mysql/schema.sql /tmp
COPY database/mysql/images.sql /tmp
COPY database/mysql/data.sql /tmp

WORKDIR /tmp

RUN apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -y lsb-release gnupg wget \
    && wget -qO- https://repo.zabbix.com/zabbix-official-repo.key | apt-key add - \
    && echo "deb https://repo.zabbix.com/zabbix/${zabbix_version}/ubuntu $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/zabbix.list \
    && apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -y -t "$(lsb_release -cs)" zabbix-server-mysql zabbix-frontend-php zabbix-agent

RUN service mysql start \
    && echo "create user '${mysql_user}'@'${mysql_host}' identified by '${mysql_password}';" | mysql \
    && echo "create database ${db_name} character set utf8 collate utf8_bin;" | mysql \
    && echo "grant all privileges on ${db_name}.* to '${mysql_user}'@'${mysql_host}' identified by '${mysql_password}';" | mysql \
    && cat schema.sql | mysql ${db_name} \
    && cat images.sql | mysql ${db_name} \
    && cat data.sql | mysql ${db_name}

CMD service mysql start && service zabbix-server start \
    && cat /var/log/zabbix*/zabbix_server.log
