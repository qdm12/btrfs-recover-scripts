#!/bin/sh

printf "RESTORE SCRIPT\n"

DISK_TO_RECOVER=/dev/mapper/cachedev_0
RESTORE_PATH=/volumeUSB1/usbshare
RECENT_FILEPATH=/mypath/recentfile.txt

# Find roots with transaction id
printf "Finding all roots..."
ROOTS_RAW=$(btrfs-find-root "$DISK_TO_RECOVER" 2> /dev/null | grep 'Well')
status=$?
if [ $status != 0 ]; then
  printf "FAILURE ($status)\n"
  return 1
fi
printf "$(echo "$ROOTS_RAW" | wc -l) found\n"

# Sort roots block numbers by transaction id
BLOCKNUMBERS=$(echo "$ROOTS_RAW" | grep -oE 'Well block [0-9]*' | grep -oE '[0-9]*')
TRANSIDS=$(echo "$ROOTS_RAW" | grep -oE '\(gen: [0-9]*' | grep -oE '[0-9]*')
TXID_BLOCKID=$(paste <(echo "$TRANSIDS") <(echo "$BLOCKNUMBERS"))
SORTED_ROOTS=$(echo "$TXID_BLOCKID" | sort -rn | uniq | cut -f 2)
printf "Searching for $RECENT_FILEPATH in the roots block numbers...\n"
printf "Trying roots block numbers: "
FIRST_VALID_ROOT=
for BLOCK in $SORTED_ROOTS; do
  printf "$BLOCK ";
  if [ "$(btrfs restore -ivD -t "$BLOCK" "$DISK_TO_RECOVER" /tmp 2> /dev/null | grep "$RECENT_FILEPATH")" != "" ]; then
    if [ "$FIRST_VALID_ROOT" = "" ]; then FIRST_VALID_ROOT="$BLOCK"; fi;
    printf "\nRoot block number $BLOCK contains $RECENT_FILEPATH - ";
    read -p "recover from this root block number? (y/n) [y]: " -r -n 1;
    echo;
    if [ "$REPLY" != "y" ]; then
      printf "Continuing... trying roots block numbers: ";
    else
      printf "Recovering $DISK_TO_RECOVER to $RESTORE_PATH with root block number $BLOCK...\n";
      btrfs restore -iv -t "$BLOCK" "$DISK_TO_RECOVER" "$RESTORE_PATH" 2>&1 | tee btrfs-restore.log;
      status=$?;
      printf "\nFinished\nYou can see the log in btrfs-restore.log\n";
      return $status;
    fi;
  fi;
done;
printf "All roots blocks numbers have been tried, recovering with first valid root block number $FIRST_VALID_ROOT\n"
btrfs restore -iv -t "$FIRST_VALID_ROOT" "$DISK_TO_RECOVER" "$RESTORE_PATH" 2>&1 | tee btrfs-restore.log
status=$?;
printf "\nFinished\nYou can see the log in btrfs-restore.log\n"
return $status;
