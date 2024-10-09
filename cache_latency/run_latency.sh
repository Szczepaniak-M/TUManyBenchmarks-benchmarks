#!/usr/bin/env bash

convert_to_bytes() {
    size=$1
    unit=$2

    case $unit in
        KiB) echo $(echo "$size * 1024 / 1" | bc) ;;
        MiB) echo $(echo "$size * 1024 * 1024 / 1" | bc) ;;
        GiB) echo $(echo "$size * 1024 * 1024 * 1024 / 1" | bc) ;;
        *) echo $size ;;
    esac
}

interpolate() {
  local start=$1
  local end=$2
  local step_size=$(("$end" / 4))

  for i in $(seq 1 3); do
    echo $(echo "$start + $i * $step_size" | bc)
  done
}

lscpu_output=$(lscpu)

l1d=$(echo "$lscpu_output" | grep "L1d" | awk '{print $3, $4}')
l2=$(echo "$lscpu_output" | grep "L2" | awk '{print $3, $4}')
l3=$(echo "$lscpu_output" | grep "L3" | awk '{print $3, $4}')

l1d_bytes=$(convert_to_bytes $(echo $l1d))
l2_bytes=$(convert_to_bytes $(echo $l2))
l3_bytes=$(convert_to_bytes $(echo $l3))

l12_bytes=$(("$l1d_bytes + $l2_bytes"))
l123_bytes=$(("$l1d_bytes + $l2_bytes + $l3_bytes"))
double_cache=$(echo "$l123_bytes * 2" | bc)
cache_sizes=(
  $(interpolate 0 $l1d_bytes)
  "$l1d_bytes"
  $(interpolate $l1d_bytes $l2_bytes)
  "$l12_bytes"
  $(interpolate $l12_bytes $l3_bytes)
  "$l123_bytes"
  $(interpolate $l123_bytes $l123_bytes)
  "$double_cache"
)

repeat=200
ool=100
for cache_size in "${cache_sizes[@]}";
do
  n=$(("$cache_size" / 8))
  numactl --cpubind=0 --membind=0 ./latency $n $repeat $ool >> results.txt
done
