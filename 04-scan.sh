#!/bin/bash

WORKDIR="../loralog"

#grep -n "listening on port" -B 3 -A 5 $WORKDIR/log.txt

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/

./log-scan $WORKDIR/log.txt
