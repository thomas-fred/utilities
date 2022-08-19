#!/bin/bash

# print some human readable CPU utilisation information

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

# use python to do the division because bc is too arcane even for me
printf "%-21s %20.2f %5d %10.1f\n" \
    $(hostname) \
    $(run_queue_15m_average) \
    $(core_count) \
    $(python3 -c "print(100 * $(run_queue_15m_average) / $(core_count))")
