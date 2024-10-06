#!/usr/bin/env bash

convert_to_bytes() {
    size=$1
    unit=$2

    case $unit in
        KiB) echo $(($size * 1024)) ;;
        MiB) echo $(($size * 1024 * 1024)) ;;
        GiB) echo $(($size * 1024 * 1024 * 1024)) ;;
        *) echo $size ;;
    esac
}

lscpu_output=$(lscpu)

l1d=$(echo "$lscpu_output" | grep "L1d" | awk '{print $3, $4}')
l2=$(echo "$lscpu_output" | grep "L2" | awk '{print $3, $4}')
l3=$(echo "$lscpu_output" | grep "L3" | awk '{print $3, $4}')

l1d_bytes=$(convert_to_bytes $(echo $l1d))
l2_bytes=$(convert_to_bytes $(echo $l2))
l3_bytes=$(convert_to_bytes $(echo $l3))

cache_sizes=("$l1d_bytes" "$l2_bytes" "$l3_bytes")
threads=(1 2 4 6 8 12 16 18 20 22 24 28 32 36 40 44 48)

echo "${cache_sizes[@]}"

repeat=100
ool=100
for cache_size in "${cache_sizes[@]}";
do
  input_size=($(echo "$cache_size * 0.8 / 8" | bc))
  for t_count in "${threads[@]}";
  do
    echo "$input_size $t_count"
    ./latency $t_count $input_size $repeat $ool >> results.txt
  done
done
