# hdd-spindown.sh
Automatic Disk Standby using Kernel diskstats and hdparm

## Summary

**hdd-spindown.sh** is a rather simple Bash script that enables automatic disk
standby for drives that do not support timeout-based spindown by firmware
(e.g. `-S` parameter for `hdparm`).


## Usage, Requirements

**hdd-spindown.sh** is best run via systemd, using the service unit provided.
In order to enable it, simply issue

    $ systemctl enable hdd-spindown.sh.service

and create a configuration file as described in the following section.

Logging output is performed via `logger`, which makes it compatible with
traditional *syslog-ng* and *journald* systems.

The following utilities are required:
 * **date**
 * **awk:** for parsing Kernel disk stats
 * **hdparm:** for actually initiating drive standby
 * **logger:** as logging interface
 * **smartctl:** for detection of SMART health-checks *(optional)*


## Configuration

**hdd-spindown.sh** uses a simple shell-style configuration file for setting
the disks to monitor. An example may look like this:

    # configuration file for hdd-spindown.sh
    
    CONF_INT=300
    CONF_DEV=( "ata-WDC_WD50EFRX-68MYMN1_WD-WX31DA43KKCY|5400" \
               "ata-WDC_WD50EFRX-68MYMN1_WD-WX81DA4HNEH5|5400" \
               "ata-WDC_WD20EARS-00MVWB0_WD-WCAZA5755786|5400" \
               "ata-WDC_WD20EARS-00MVWB0_WD-WMAZA3570471|5400" )
  
  `CONF_INT` specifies the monitoring interval in seconds while `CONF_DEV`
  features a list of devices to monitor, as well as their timeout value in
  seconds, separated by the pipe symbol '|'.
  
  Note that devices may be specified using their UUID (as shown) or node
  name (e.g. 'sda'). The interval option may be omitted, which sets the
  default interval of 5 minutes.

## License

This software is released under the terms of the MIT License, see file
*LICENSE*.
