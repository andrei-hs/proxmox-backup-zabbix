O objetivo deste código é monitorar os backups do proxmox (Datacenter > Backup).

São coletados dados como "Nome do Backup", "Node aonde é realizado", "Storage", "Log" e "Status". Essas informações são enviadas ao zabbix para que seja possível o monitoramento completo dessa funcionalidade.

# Requisitos
Para poder realizar a configuração do script é necessário ter instalado no servidor Proxmox:

- python3
- zabbix_sender
- zabbix_agent

# Configuração
Tutorial passo a passo como configurar este monitoramento.
## Proxmox
Baixe os scripts no servidor:
```
cd /opt;
git clone https://github.com/andrei-hs/proxmox-backup-zabbix.git pve-scripts
```

Configure o proxmox para executar automaticamente este script em qualquer backup que estiver configurado:
```
echo "script: /opt/pve-scripts/backup-status.sh" >> /etc/vzdump.conf
```

Adiciona a descoberta de rede no Zabbix Agent:
```
echo "UserParameter=proxmox.qemu.hasbackup[*],/opt/pve-scripts/vm-backup-ldd.py $1 $2 $3 $4 $5" >> /etc/zabbix/zabbix_agentd.conf
```

# Scripts
Explicação resumida da utilidade de cada script
## backup-status.sh
Este arquivo é executado quando o proxmox faz o backup e informa para o zabbix se o backup funcionou ou não.

## vm-backup-ldd.py
Tem a funcionalidade de falar com a API do Proxmox e realizar uma descoberta para saber quais VMs estão com backup configurado e criar automaticamente um item no zabbix da VM que irá receber as informações enviadas pelo arquivo backup-status.py quando for executado.

Como este script solicita as informações via API, ele não necessariamente precisa ser configurado diretamente no servidor proxmox, desde que o zabbix consiga executá-lo e o script possa comunicar com o proxmox para fazer a descoberta, você pode colocá-lo aonde preferir.
