#!/usr/bin/env python

from __future__ import division
import os
import signal
import sys
import time


def signal_handler(signal, frame):
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

def get_cpu_temp(fahrenheit=False):
    """
    """
    # http://www.mjmwired.net/kernel/Documentation/hwmon/sysfs-interface
    cat = lambda file: open(file, 'r').read().strip()
    base = '/sys/class/hwmon/hwmon0/device'
    try:
        label = cat(os.path.join(base, 'temp1_label'))
    except IOError:
        pass
    name = cat(os.path.join(base, 'name'))
    temp = int(cat(os.path.join(base, 'temp1_input'))) / 1000
    crit = int(cat(os.path.join(base, 'temp1_crit'))) / 1000
    crit_alarm = int(cat(os.path.join(base, 'temp1_crit_alarm'))) / 1000
    if fahrenheit:
        temp = temp * 1.8 + 32
        crit = crit * 1.8 + 32
        crit_alarm = crit_alarm * 1.8 + 32
    cputemp = {'name': name, 'temp':temp, 'crit': crit, 'crit_alarm': crit_alarm}
    return cputemp

if __name__ == '__main__':
    while True:
        print get_cpu_temp()
        time.sleep(2)
