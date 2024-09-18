#! /usr/bin/env python

import sys

for line in sys.stdin:
    fields = line.strip().split(',')

    if(fields[0] != '\"PATENT\"'):
        if(fields[8] == ""):
            print("{0}\t{1}".format(fields[4], 0))
        else:
            print("{0}\t{1}".format(fields[4], fields[8]))
