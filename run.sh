#!/bin/bash

# change location to current directory if run from another place
cd "$(dirname "$0")"

# Kill all the running conkys
killall conky

# Run conky on the background
conky -c main.rc  &
conky -c rings.rc &