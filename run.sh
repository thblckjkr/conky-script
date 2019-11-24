#!/bin/bash

killall conky

conky -c main.rc  &
conky -c files.rc &