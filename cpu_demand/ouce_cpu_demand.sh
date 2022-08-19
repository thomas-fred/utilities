#!/bin/bash

# for this to work, you must have already put your keys on the hosts
# also, the permissions for the remote .ssh folder (and others) must be correct
# see here for more details: https://unix.stackexchange.com/a/36687

USER=$1

SSH_TIMEOUT=3
HOST_START=1
HOST_END=34

if [[ -z $USER ]]; then
    echo "must supply user, usage:"
    echo "$0 cenv0899"
    exit 1
fi


printf "%-21s %20s %5s %10s\n" "Hostname" "Processes (15m avg.)" "Cores" "Demand (%)"

for ID in $(seq $HOST_START $HOST_END); do
    HOST="linux${ID}.ouce.ox.ac.uk"

    # BatchMode means if we get a password prompt, fail request
    # N.B. trailing ampersand to background jobs for async connections
    ssh \
        -o ConnectTimeout=$SSH_TIMEOUT \
        -o BatchMode=yes \
        -l ${USER} \
        -q \
        ${HOST} \
        'bash' < ~/bin/cpu_demand/cpu_demand.sh &
done

# wait for backgrounded jobs to complete
wait
