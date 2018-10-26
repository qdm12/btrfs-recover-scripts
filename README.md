# BTRFS Recover scripts

*Scripts to help you recover the latest files you have lost in a BTRFS volume*

1. Download the scripts
   ```sh
   wget https://raw.githubusercontent.com/qdm12/btrfs-recover-scripts/master/unmount.sh
   wget https://raw.githubusercontent.com/qdm12/btrfs-recover-scripts/master/restore.sh
   wget https://raw.githubusercontent.com/qdm12/btrfs-recover-scripts/master/limit-restore.sh   
   ```
1. Modify the variables in the scripts at the top:
    - `DISK_TO_RECOVER` is the path to the unmounted disk (BTRFS volume) to recover
    - `RESTORE_PATH` is the path to which store the restored data from the disk
    - `RECENT_FILEPATH` is a full or partial path or path+filename or filename of a recent file you want to recover
1. Make them executable
    ```sh
    sudo chmod 700 unmount.sh restore.sh limit-restore.sh  
    ```
1. If you need to, `./unmount.sh` to unmount your BTRFS volume
1. Then run `./restore.sh` to find the right root block number and recover your files
1. At the same time, you can run `./limit-restore.sh` to pause the restore process in case your restore drive is almost full.
