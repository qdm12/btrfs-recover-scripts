# BTRFS Recover scripts

*Scripts to help you recover the latest files you have lost in a BTRFS volume*

## Step 1: Unmounting your BTRFS volume

1. Download the *unmount* script

   ```sh
   wget -q https://raw.githubusercontent.com/qdm12/btrfs-recover-scripts/master/unmount.sh
   ```

1. Change the variable `DISK_TO_RECOVER` to your BTRFS volume name (say `/dev/mapper/cachedev_0`) in *unmount.sh*:

   ```sh
   sed -i 's/^DISK_TO_RECOVER=*$/DISK_TO_RECOVER=/dev/mapper/cachedev_0' unmount.sh
   ```

1. Make the script executable and run it:

    ```sh
    sudo chmod 700 unmount.sh
    sudo ./unmount.sh
    ```

1. Verify your drive is not present anymore with `df -H`

## Step 2: Restore the drive

1. Download the *restore* script

   ```sh
   wget -q https://raw.githubusercontent.com/qdm12/btrfs-recover-scripts/master/restore.sh
   ```

1. Change the variables in *restore.sh*
    - `DISK_TO_RECOVER` is the path to the unmounted BTRFS volume to recover (say `/dev/mapper/cachedev_0`)
    - `RESTORE_PATH` is the path to which the restored data from the disk will be written (say `/volumeUSB1/usbshare`)
    - `RECENT_FILEPATH` is a full or partial path or path+filename or filename of a recent file you want to recover, to act as a time reference (say `/data/homes/myhome/recentfile.txt`)

   ```sh
   sed -i 's/^DISK_TO_RECOVER=*$/DISK_TO_RECOVER=/dev/mapper/cachedev_0' restore.sh
   sed -i 's/^RESTORE_PATH=*$/RESTORE_PATH=/volumeUSB1/usbshare' restore.sh
   sed -i 's/^RECENT_FILEPATH=*$/RECENT_FILEPATH=/data/homes/myhome/recentfile.txt' restore.sh
   ```

1. Make the script executable and run it:

    ```sh
    sudo chmod 700 restore.sh
    sudo ./restore.sh
    ```

## Optional step 3: Limit recovery drive usage

If your drive is not large enough to recover the necessary data from the BTRFS volume, this is for you.

1. Open **another shell**
1. Download the *limit-restore* script

   ```sh
   wget -q https://raw.githubusercontent.com/qdm12/btrfs-recover-scripts/master/limit-restore.sh
   ```

1. Change the variables in *limit-restore.sh*
    - `DISK_TO_RECOVER` is the path to the unmounted BTRFS volume to recover (say `/dev/mapper/cachedev_0`)
    - `RESTORE_PATH` is the path to which the restored data from the disk will be written (say `/volumeUSB1/usbshare`)

   ```sh
   sed -i 's/^DISK_TO_RECOVER=*$/DISK_TO_RECOVER=/dev/mapper/cachedev_0' restore.sh
   sed -i 's/^RESTORE_PATH=*$/RESTORE_PATH=/volumeUSB1/usbshare' restore.sh
   ```

1. Make the script executable and run it:

    ```sh
    sudo chmod 700 limit-restore.sh
    sudo ./limit-restore.sh
    ```

This will automatically pause the restore process when your restore drive is 90% full.
