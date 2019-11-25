#!/bin/bash

killall conky

conky -c main.rc  &
conky -c rings.rc &