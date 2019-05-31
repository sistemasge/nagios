#!/bin/bash
rsync -avAHS --stats --sparse --delete /opt/zimbra/ root@10.52.1.119:/opt/zimbra.bkp &> /opt/backup/log/backup_rsync_zimbra_PARADO_$(date +%F_%T).log
