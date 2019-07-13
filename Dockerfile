FROM ubuntu:18.04

RUN apt update \
    && apt install -y lsb-release gnupg wget \
    && wget -qO- https://repo.zabbix.com/zabbix-official-repo.key | apt-key add - \
    && echo "deb https://repo.zabbix.com/zabbix/4.2/ubuntu $(lsb_release -cs) main" \
    && apt update \
    && apt install -y zabbix-server-mysql

CMD service zabbix-server start \
    && cat /var/log/zabbix*/zabbix_server.log
