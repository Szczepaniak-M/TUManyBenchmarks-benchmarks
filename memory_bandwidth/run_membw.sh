#!/usr/bin/env bash

echo "threads,bw,sum" > results.csv
threads=(1 2 4 6 8 12 16 18 20 22 24 28 32 36 40 44 48) 
# fill 70% of RAM size with uint64_t
size=$(free -b | grep Mem: | awk '{print $2}')
input_size=$(echo "$size * 0.7 / 8" | bc)

for t_count in "${threads[@]}";
do
  numactl --cpubind=0 --membind=0 ./membw $input_size $t_count 10 >> results.csv
done
