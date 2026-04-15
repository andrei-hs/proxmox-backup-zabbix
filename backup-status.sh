#!/usr/bin/env bash
#
#	Script de Status backup Proxmox
#
#17/09/25 - Andrei Henrique Santos

ZABBIX_SERVER=$(awk -F= '/^ServerActive=/{print $2}' /etc/zabbix/zabbix_agentd.conf | tail -n 1)

ZABBIX_SERVER_IP=$(echo "$ZABBIX_SERVER" | cut -d':' -f1)
ZABBIX_SERVER_PORT=$(echo "$ZABBIX_SERVER" | cut -d':' -f2)
ZABBIX_NODE=$(zabbix_agentd -t system.hostname | awk -F'[|\\]]' '{print $2}')
ZABBIX_KEY="proxmox.backup"

phase=$1
vmid=$3

sendToZabbix() {
	local send_to=$1
	local port=$2
	local host=$3
	local key=$4
	local data=$5

	zabbix_sender -z "$send_to" -p "$port" -s "$host" -k "$key" -o "$data"
}

case "$phase" in
	"backup-end")
		sendToZabbix "$ZABBIX_SERVER_IP" "$ZABBIX_SERVER_PORT" "$ZABBIX_NODE" "$ZABBIX_KEY.status[$ZABBIX_NODE,$vmid,$STOREID]" 1
		;;
	"backup-abort")
		sendToZabbix "$ZABBIX_SERVER_IP" "$ZABBIX_SERVER_PORT" "$ZABBIX_NODE" "$ZABBIX_KEY.status[$ZABBIX_NODE,$vmid,$STOREID]" 0
		;;
	"log-end" | "log-abort")
		log=$(<"$LOGFILE")
		sendToZabbix "$ZABBIX_SERVER_IP" "$ZABBIX_SERVER_PORT" "$ZABBIX_NODE" "$ZABBIX_KEY.log[$ZABBIX_NODE,$vmid,$STOREID]" "$log"
		;;
esac
