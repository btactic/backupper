# backupper

Incremental backups with rsync and hard links.


## Installation

1. Clone repository
2. Run `install.sh`.



## Setup

1. Setup destination machine so that ssh connections can be made from origin machine without a password:
    - If `~/.ssh/id_rsa.pub` file was not to exist you need to create it with `# ssh-keygen`.
    - `# ssh-copy-id -i ~/.ssh/id_rsa.pub -p 22 backupper@172.16.0.101`
    - Verify you can connect from origin machine to destination machine by the means of ssh (without a password)

2. Rename `/usr/local/etc/backupper/custom.conf.sample` filename to `/usr/local/etc/backupper/custom.conf`.

3. Edit `/usr/local/etc/backupper/custom.conf` file with your specific backup configuration.
