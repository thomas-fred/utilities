#!/bin/bash

# print some human readable resource utilisation information

function core_count() {
    # lscpu in -p(arsable) format
    # sed to remove header comments
    # count number of core entries
    COUNT=$(lscpu -p | sed '/^#/d' | wc -l)
    echo $COUNT
}

function run_queue_15m_average() {
    # example uptime output:
    #  14:54:51 up 42 days,  8:16, 12 users,  load average: 2.00, 2.00, 1.99
    # use awk to select last item, the 15 minute average of number of processes
    # wanting to execute
    AVERAGE=$(uptime | awk '{print $(NF)}')
    echo $AVERAGE
}

function tot_mem_gb() {
    # example output from free --giga
    #                total        used        free      shared  buff/cache   available
    # Mem:             134          20         109           0           4         112
    # Swap:              2           1           1
    TOT_MEM_GB=$(free --giga | grep Mem: | awk '{printf $2}')
    echo $TOT_MEM_GB
}

function used_mem_gb() {
    # example output from free --giga
    #                total        used        free      shared  buff/cache   available
    # Mem:             134          20         109           0           4         112
    # Swap:              2           1           1
    USED_MEM_GB=$(free --giga | grep Mem: | awk '{printf $3}')
    echo $USED_MEM_GB
}

# use python to do the division because bc is too arcane even for me
printf "%-21s %20.2f %5d %14.1f %12d %13d %19.2f\n" \
    $(hostname) \
    $(run_queue_15m_average) \
    $(core_count) \
    $(python3 -c "print(100 * $(run_queue_15m_average) / $(core_count))") \
    $(tot_mem_gb) \
    $(used_mem_gb) \
    $(python3 -c "print(100 * $(used_mem_gb) / $(tot_mem_gb))")
