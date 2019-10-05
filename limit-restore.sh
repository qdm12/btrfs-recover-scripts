#!/bin/sh

printf "LIMIT RESTORE SCRIPT\n"

DISK_TO_RECOVER=/dev/mapper/cachedev_0
RESTORE_PATH=/volumeUSB1/usbshare

printf "Finding PID of restore process..."
RESTORE_PID=`ls -l /proc/[0-9]*/fd/* 2> /dev/null | grep "$DISK_TO_RECOVER" | grep -oE '/proc/.*/f' | grep -oE '[0-9]*'`
if [ `echo "$RESTORE_PID" | wc -l` -gt 1 ]; then
  printf "\nPlease make sure there is only the BTRFS recovery process accessing your unmounted BTRFS volume.\n";
  printf "You have the following processes accessing it currently: $RESTORE_PID";
  exit 1;
fi
printf "$RESTORE_PID\n"
printf "Waiting for $RESTORE_PATH to reach 90% disk space to STOP process $RESTORE_PID...\n"
while [ true ]; do
  while [ `df "$RESTORE_PATH" | grep -Eo '[0-9]*%' | grep -Eo '[0-9]*'` -lt 90 ]; do
    sleep 5;
  done;
  kill -STOP "$RESTORE_PID";
  printf "Stopped process $RESTORE_PID\n";
  printf "WARNING: Do not unmount $RESTORE_PATH or $DISK_TO_RECOVER !";
  printf "Empty $RESTORE_PATH to another extra drive and then continue...";
  read -p "[WAITING FOR KEY]" -n 1 -r;
  echo;
  kill -CONT "$RESTORE_PID";
done