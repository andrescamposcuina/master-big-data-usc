#! /usr/bin/env python

import sys

(last_key, total) = (None, 0)
counter = 0.0

for line in sys.stdin:
    (key, value) = line.strip().split()

    if last_key and last_key != key:
        print("{0}\t{1}".format(last_key, float(total)/float(counter)))
        (last_key, total) = (key, int(value))
        counter = 1.0
    else:
        (last_key, total) = (key, total + int(value))
        counter += 1.0

if last_key:
    print("{0}\t{1}".format(last_key, float(total)/float(counter)))


