#!/bin/bash

# query the linux.ouce.ox.ac.uk nodes to see how busy they are

# for this to work, you must have already put your keys on the hosts
# also, the permissions for the remote .ssh folder (and others) must be correct
# see here for more details: https://unix.stackexchange.com/a/36687

USER=$1

SSH_TIMEOUT=5
HOST_START=1
HOST_END=34

if [[ -z $USER ]]; then
    echo "must supply user, example usage:"
    echo "$0 cenv0899"
    exit 1
fi

TEMP_RESULTS_PATH=/tmp/$(date --iso-8601=seconds)_ouce_cluster_load.dat

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
        'bash' < ~/utilities/cpu_demand/cpu_demand.sh >> $TEMP_RESULTS_PATH &
done

# print header
printf "%-21s %20s %5s %10s %5s %5s %5s\n" "Hostname" "Processes (15m avg.)" "Cores" "CPU demand (%)" "Mem tot [GB]" "Mem used [GB]" "Mem utilisation (%)"

# wait for responses
PID=$!  # process ID of last job to be launched
while [ -d /proc/$PID ]
do
    sleep 0.1
done

# after sleeping, every backgrounded job should have completed
# as they all have the same timeout, but to be sure we've got all the results,
# use wait to ensure backgrounded jobs have completed
wait

# check a response file exists
if [ -f "$TEMP_RESULTS_PATH" ]; then
    # if it does, check it's not empty
    if [ -s "$TEMP_RESULTS_PATH" ]; then
        # sort the nodes to descending demand order and print to stdout
        sort --key 4 --numeric < $TEMP_RESULTS_PATH | tac
    else
        # there's a file, but it's empty, i.e. we probably couldn't connect
        printf "\rError: No responses. Are your keys on the remotes?\n"
    fi
else
    # we never seem to end up here, i.e. a file is always created
    printf "\rError: No response file generated.\n"
fi

rm $TEMP_RESULTS_PATH
