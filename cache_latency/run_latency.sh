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
  local diff=$(("$end - $start"))
  local step_size=$(("$diff" / 4))

  # Generate the interpolated values
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
double_l3_bytes=$(echo "$l3_bytes * 2" | bc)

# Create an array of cache sizes with interpolated values between 0, L1D, L2, L3 and 2*L3
cache_sizes=(
  $(interpolate 0 $l1d_bytes 3)
  "$l1d_bytes"
  $(interpolate $l1d_bytes $l2_bytes 3)
  "$l2_bytes"
  $(interpolate $l2_bytes $l3_bytes 3)
  "$l3_bytes"
  $(interpolate $l3_bytes double_l3_bytes 3)
  "$double_l3_bytes"
)

repeat=200
ool=100
for cache_size in "${cache_sizes[@]}";
do
  n=$(("$cache_size" / 8))
  ./latency $n $repeat $ool >> results.txt
done
