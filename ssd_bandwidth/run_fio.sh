#!/usr/bin/env bash
# TODO: Dynamically detect the non-boot nvme device
lsblk_output=$(lsblk)
size_str=$(echo "$lsblk_output" | grep "nvme1n1" | awk '{print $4}')
ssd_size=$(echo $size_str | sed 's/\([0-9]*\)\.[0-9]*\([GT]\)/\1\2/')


sudo chmod 666 /dev/nvme1n1
sudo fio --name=readio --rw=write --numjobs=16 --refill_buffers --ioengine=libaio --group_reporting --iodepth=128 --bs=4k --filename=/dev/nvme1n1 --size="$ssd_size" --direct=1 --output-format=json --output=results-write.json
experiments=("randwrite" "read" "randread")
for exp in "${experiments[@]}"
do
    output_file="results-${exp}.json"
    sudo fio --name=readio --rw="${exp}" --numjobs=16 --refill_buffers --ioengine=libaio --time_based --runtime=60s --group_reporting --iodepth=128 --bs=4k --filename=/dev/nvme1n1 --size=20G --direct=1 --output-format=json --output="$output_file"
done