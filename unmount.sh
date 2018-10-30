#!/bin/sh

printf "UNMOUNT VOLUME SCRIPT\n"

DISK_TO_RECOVER=/dev/mapper/cachedev_0

# Unmounting
printf "Unmounting $DISK_TO_RECOVER ..."
umount "$DISK_TO_RECOVER"
status=$?
if [ $status = 32 ]; then
  printf "ALREADY DISMOUNTED\n"
else
  while [ $status != 0 ]
  do
    printf "FAILED ($status)\n"
    # Find the mounted directory
    DISK_MOUNT=$(df "$DISK_TO_RECOVER" | tail -n 1 | grep -oE '/.*')
    if [ "$DISK_MOUNT" = "/dev" ]; then
      printf "WARNING: $DISK_TO_RECOVER seems mounted at /dev\n"
      break
    fi
    printf "$DISK_TO_RECOVER is mounted at $DISK_MOUNT\n"
    PIDS=$(ls -l /proc/[0-9]*/fd/* 2> /dev/null | grep "$DISK_MOUNT" | grep -oE '/proc/.*/f' | grep -oE '[0-9]*')
    printf "About to kill the following processes to unmount $DISK_TO_RECOVER mounted at $DISK_MOUNT : "
    for pid in $PIDS; do printf "$pid "; done; printf "\n"
    read -p "Continue? (y/n) [y]:" -n 1 -r
    echo
    if [[ "$REPLY" != "y" && "$REPLY" != "" ]]; then
      return 0
    fi
    printf "Processes killed: "
    for pid in $PIDS; do kill $pid; printf "$pid "; done; printf "\n"
    printf "Unmounting $DISK_TO_RECOVER ..."
    umount "$DISK_TO_RECOVER"
    status=$?
  done
  printf "SUCCESS\n"
fi