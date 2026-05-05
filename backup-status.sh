#!/usr/bin/env bash
#
#	Script de Status backup Proxmox
#
#17/09/25 - Andrei Henrique Santos

ZABBIX_KEY="proxmox.backup"
ZABBIX_CONF_FILE="/etc/zabbix/zabbix_agentd.conf"
ZABBIX_NODE=$(zabbix_agentd -t system.hostname | awk -F'[|\\]]' '{print $2}')

phase=$1
vmid=$3

sendToZabbix() {
	local config_file=$1
	local host=$2
	local key=$3
	local data=$4

	zabbix_sender -c "$config_file" -s "$host" -k "$key" -o "$data"
}

case "$phase" in
	"backup-end")
		sendToZabbix "$ZABBIX_CONF_FILE" "$ZABBIX_NODE" "$ZABBIX_KEY.status[$ZABBIX_NODE,$vmid,$STOREID]" 1
		;;
	"backup-abort")
		sendToZabbix "$ZABBIX_CONF_FILE" "$ZABBIX_NODE" "$ZABBIX_KEY.status[$ZABBIX_NODE,$vmid,$STOREID]" 0
		;;
	"log-end" | "log-abort")
		log=$(<"$LOGFILE")
		sendToZabbix "$ZABBIX_CONF_FILE" "$ZABBIX_NODE" "$ZABBIX_KEY.log[$ZABBIX_NODE,$vmid,$STOREID]" "$log"
		;;
esac
