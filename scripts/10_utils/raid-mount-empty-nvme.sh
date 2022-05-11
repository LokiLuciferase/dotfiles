#!/usr/bin/env bash
# Checks for NVMe devices without a file system, and mounts them (as RAID0 if more than 1).

[[ -z "$1" ]] && echo "No mountpoint passed." && exit 1
[[ ! -d "$1" ]] && echo "Mountpoint $1 does not exist." && exit 1
[[ ! -z "$(lsblk | grep raid0)" ]] && exit 0  # raid0 already present

# get unmounted drives
NVMES=$(lsblk --noheadings --raw -o NAME,MOUNTPOINT | awk '$1~/[[:digit:]]/ && $2 == ""' | grep "nvme[0-9]n[0-9] $" | tr '\n' ' ')

# prepending "/dev/" and checking that the volume has no partitions
NVMES=($NVMES)
FREE_NVMES=()
for i in ${!NVMES[@]}; do
    NVMES[i]=/dev/${NVMES[i]}
    HAS_FS=$(sudo /sbin/sfdisk -d ${NVMES[i]})
    [[ "$HAS_FS" = "" ]] && FREE_NVMES+=( ${NVMES[i]} )
done

# if there is only a single unmounted, unused, unpartitioned one, mount it directly
# else make RAID0
if [[ ${#FREE_NVMES[@]} -eq 1 ]]; then
    echo "one NVMe disk found: ${FREE_NVMES[@]}"
    sudo mkfs.xfs ${FREE_NVMES[0]}
    sudo mount ${FREE_NVMES[0]} "$1"
    sudo chmod -R 777 "$1"
elif [[ ${#FREE_NVMES[@]} -ge 2 ]]; then
    echo "multiple NVMe disks found: ${FREE_NVMES[@]}"
    sudo mdadm --create --verbose /dev/md0 --level=0 --name=MY_RAID --raid-devices=${#FREE_NVMES[@]} "${FREE_NVMES[@]}"
    sudo mdadm --detail /dev/md0
    sudo mkfs.xfs -L MY_RAID /dev/md0
    sudo mount /dev/md0 "$1"
    sudo chmod -R 777 "$1"
else
    echo "no NVMe disks found."
fi
