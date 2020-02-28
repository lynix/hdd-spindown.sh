# hdd-spindown.sh

[README](README.md) | [中文文档](README_zh.md)

Automatic Disk Standby using Kernel diskstats and hdparm


## Summary

**hdd-spindown.sh** is a rather simple Bash script that enables automatic disk
standby for drives that do not support timeout-based spindown by firmware
(e.g. `-S` parameter for `hdparm`).


## Usage, Requirements

**hdd-spindown.sh** is best run via systemd, using the service unit provided.
In order to enable it, simply issue

    $ systemctl enable hdd-spindown.service

and adapt configuration file `/etc/hdd-spindown.rc` to suit your needs.

Apart from *coreutils* the following is required:
 * **smartctl:** for detection of drive status and SMART self-checks
 * **hdparm** for actually initiating drive standby
 * **grep** for utility output parsing

The following is optional, depending on the features used:
 * **logger** if syslog interface enabled
 * **ping** if host monitoring enabled


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

Note that devices may be specified using their ID (as shown) or device
name (e.g. 'sda'). The interval option may be omitted, which sets the
default interval of 5 minutes.

For a complete list of options please see the example `hdd-spindown.rc`.


## License

This software is released under the terms of the MIT License, see file
*LICENSE*.
