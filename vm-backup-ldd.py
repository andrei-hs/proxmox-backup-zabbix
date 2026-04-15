#!/usr/bin/env python3
#
#	LDD VMs com Backup Configurado
#
#Andrei Henrique Santos
#18/09/25

import sys
import json
import http.client
import ssl

if len(sys.argv) < 6:
    print("Usage: vm-backup-ldd.py <HOST> <PORT> <TOKEN> <TOKEN-SECRET> <NODE-NAME>")
    sys.exit(1)

PROXMOX_HOST = sys.argv[1]
PROXMOX_PORT = sys.argv[2]
API_TOKEN_ID = sys.argv[3]
API_TOKEN_SECRET = sys.argv[4]
PROXMOX_NODE = sys.argv[5]

def proxmox_api_get(path):
    context = ssl._create_unverified_context()
    connection = http.client.HTTPSConnection(PROXMOX_HOST, PROXMOX_PORT, context=context)
    headers = {
            "Authorization": f"PVEAPIToken={API_TOKEN_ID}={API_TOKEN_SECRET}"
            }
    connection.request("GET", f"/api2/json{path}", headers=headers)
    response = connection.getresponse()
    if response.status != 200:
        connection.close()
        return None
    data = response.read()
    connection.close()
    return json.loads(data)["data"]

backupScheduled = proxmox_api_get("/cluster/backup")
vms = proxmox_api_get(f"/nodes/{PROXMOX_NODE}/qemu/")
vmsNoBackupConfigured = proxmox_api_get(f"/cluster/backup-info/not-backed-up")

vmids_noBackup = set()
for vm in vmsNoBackupConfigured:
    vmids_noBackup.add(vm["vmid"])

vms_filtered = []
for vm in vms:
    if vm["vmid"] in vmids_noBackup:
        continue

    vm["node"] = PROXMOX_NODE
    
    for backup in backupScheduled:
        backupOfVmids = map(int, backup["vmid"].split(","))

        if vm["vmid"] in backupOfVmids and backup["enabled"]:
            vm_data = dict(vm)
            vm_data["backup_storage"] = backup["storage"]
            vm_data["next_backup"] = backup["next-run"]
            vms_filtered.append(vm_data)


stdout = json.dumps({
    "data": vms_filtered
    })

print(stdout)
