#!/bin/bash

WORKDIR="../loralog"

grep -n "listening on port" -B 3 -A 5 $WORKDIR/log.txt

