#!/usr/bin/env bash

sleep 5
iperf -c node-2 -t 300 -P 3 -i 1 -f m >> results_1.txt
sleep 240
iperf -c node-2 -t 100 -P 3 -i 1 -f m >> results_2.txt
