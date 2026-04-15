# backup-status.sh
Este arquivo é executado quando o proxmox faz o backup e informa para o zabbix se o backup funcionou ou não.

# vm-backup-ldd.py
Tem a funcionalidade de falar com a API do Proxmox e realizar uma descoberta para saber quais VMs estão com backup configurado e criar automáticamente um item no zabbix da VM que irá receber as informações enviadas pelo arquivo backup-status.py quando for executado.
