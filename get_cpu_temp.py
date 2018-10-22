#!/usr/bin/env python

from __future__ import division
import os
import multiprocessing
import signal
import sys
import time

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

#from collections import namedtuple

num_cpu = multiprocessing.cpu_count()

#_nt_cpu_temp = namedtuple('cputemp', 'name temp max critical')

def signal_handler(signal, frame):
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

def get_cpu_temp(fahrenheit=False):
    """Return temperatures expressed in Celsius for each physical CPU
    installed on the system as a list of namedtuples as in:

    >>> get_cpu_temp()
    [cputemp(name='atk0110', temp=32.0, max=60.0, critical=95.0)]
    """
    # http://www.mjmwired.net/kernel/Documentation/hwmon/sysfs-interface
    cat = lambda file: open(file, 'r').read().strip()
    base = '/sys/class/hwmon/'
    ls = sorted(os.listdir(base))
    assert ls, "%r is empty" % base
    ret = []
    for hwmon in ls:
        hwm = os.path.join(base, hwmon)
        for cpu in range(1, num_cpu+1):
            try:
                label = cat(os.path.join(hwm, 'temp%s_label' % str(cpu)))
            except IOError:
                continue
            #print label
            #assert 'cpu temp' in label.lower(), label
            name = cat(os.path.join(hwm, 'name'))
            temp = int(cat(os.path.join(hwm, 'temp%s_input' % str(cpu)))) / 1000
            max_ = int(cat(os.path.join(hwm, 'temp%s_max' % str(cpu)))) / 1000
            crit = int(cat(os.path.join(hwm, 'temp%s_crit' % str(cpu)))) / 1000
            #digits = (temp, max_, crit)
            #if fahrenheit:
                #digits = [(x * 1.8) + 32 for x in digits]
            cputemp = {'name': name, 'temp':temp, 'max': max_, 'crit': crit}
            ret.append(cputemp)
    return ret

if __name__ == '__main__':
    while True:
        cputemp = get_cpu_temp()
        for temp in cputemp:
            if temp['temp'] < 50:
                sys.stdout.write(bcolors.OKGREEN + str(temp['temp'])+' ')
            elif temp['temp'] >= 50 and temp['temp']< 60:
                sys.stdout.write(bcolors.WARNING + str(temp['temp'])+' ')
            else:
                sys.stdout.write(bcolors.FAIL + str(temp['temp'])+' ')
        sys.stdout.write('\r')
        sys.stdout.flush()
        time.sleep(2)
