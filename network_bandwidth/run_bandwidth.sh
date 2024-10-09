#!/usr/bin/env bash

sleep 5
num_threads=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
iperf -c node-2 -t 300 -P $num_threads -i 1 -f g >> results_1.txt
sleep 240
iperf -c node-2 -t 100 -P $num_threads -i 1 -f g >> results_2.txt
