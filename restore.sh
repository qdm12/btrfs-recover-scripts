#!/bin/sh

printf "RESTORE SCRIPT"

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
for BLOCK in $SORTED_ROOTS; do printf "$BLOCK "; if [ "$(btrfs restore -ivD -t "$BLOCK" "$DISK_TO_RECOVER" /tmp 2> /dev/null | grep "$RECENT_FILEPATH")" != "" ]; then printf "\n$BLOCK root block number contains $RECENT_FILEPATH\nTrying roots block numbers: "; fi; done
read -p "Which root block number do you want to recover from (the first one is better)? " -r
echo
btrfs restore -iv -t "$REPLY" "$DISK_TO_RECOVER" "$RESTORE_PATH"