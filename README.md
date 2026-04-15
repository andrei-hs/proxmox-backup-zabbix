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
```shell
cd /opt;
git clone https://github.com/andrei-hs/proxmox-backup-zabbix.git pve-scripts
```

Configure o proxmox para executar automaticamente este script em qualquer backup que estiver configurado:
```shell
echo "script: /opt/pve-scripts/backup-status.sh" >> /etc/vzdump.conf
```
> [!NOTE]
> Se preferir configurar a execução do script por backup manualmente, utilize:
> ```shell
> pvesh set /cluster/backup/BAKCUPID --script /opt/pve-scripts/backup-status.sh
> ```

Adiciona a descoberta de rede no Zabbix Agent:
```shell
echo "UserParameter=proxmox.qemu.hasbackup[*],/opt/pve-scripts/vm-backup-ldd.py $1 $2 $3 $4 $5" >> /etc/zabbix/zabbix_agentd.conf
```
> [!NOTE]
> Essa configuração do **vm-backup-ldd.py** não necessariamente precisa ser feita no Zabbix Agent do Proxmox já que o arquivo se comunica via API, portanto desde que o Zabbix consiga executar o script e ele acesse a API do Proxmox não haverá problema.

> [!TIP]
> Uma dica é utilizar esse script no próprio Zabbix Server ou Proxy dependendo de como é sua infraestrutura, para que desta forma você não precise ter várias cópias do mesmo código para inúmeros Proxmox que queira monitorar.

## Zabbix
Para configurar esse monitoramento no zabbix, basta baixar o arquivo **proxmox-bkp-zabbix.yaml** e importá-lo na aba **Configuração\Templates**. Após este processo, adicione o template criado no host proxmox que gostaria de monitorar e preencha as informações necessárias nas macros.

# Scripts
Explicação resumida da utilidade de cada script
## backup-status.sh
Este arquivo é executado quando o proxmox faz o backup e informa para o zabbix se o backup funcionou ou não.

## vm-backup-ldd.py
Tem a funcionalidade de falar com a API do Proxmox e realizar uma descoberta para saber quais VMs estão com backup configurado e criar automaticamente um item no zabbix da VM que irá receber as informações enviadas pelo arquivo backup-status.py quando for executado.
