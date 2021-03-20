#!/bin/bash

# hdd-spindown.sh
# ---------------
# Automatic Disk Standby Using Kernel Diskstats and hdparm
# (C) 2011-2021 Alexander Koch <mail@alexanderkoch.net>
#
# Released under the terms of the MIT License, see 'LICENSE'


# default configuration file
readonly CONFIG="${CONFIG:-/etc/hdd-spindown.rc}"


function check_req() {
	FAIL=0
	for CMD in $@; do
		which $CMD &>/dev/null && continue
		echo "error: missing '$CMD' executable in PATH" >&2
		FAIL=1
	done
	[ $FAIL -ne 0 ] && exit 1
}

function log() {
	if [ $CONF_SYSLOG -eq 1 ]; then
		logger -t "hdd-spindown.sh" --id=$$ "$1"
	else
		echo "$1"
	fi
}

function selftest_active() {
	$SMARTCTL -a "/dev/$1" | grep -q "Self-test routine in progress"
	return $?
}

function dev_stats() {
	read R_IO R_M R_S R_T W_IO REST < "/sys/block/$1/stat"
	echo "$R_IO $W_IO"
}

function dev_isup() {
	$SMARTCTL -i -n standby "/dev/$1" | grep -q ACTIVE
	return $?
}

function dev_spindown() {
	# skip spindown if already spun down
	dev_isup "$1" || return 0

	# omit spindown if SMART Self-Test in progress
	selftest_active "$1" && return 0

	# spindown disk
	log "suspending $1"
	hdparm -qy "/dev/$1"
	if [ $? -gt 0 ]; then
		log "failed to suspend $1"
		return 1
	fi

	return 0
}

function dev_spinup() {
	# skip spinup if already online
	dev_isup "$1" && return 0

	# read raw blocks, bypassing cache
	log "spinning up $1"
	dd if=/dev/$1 of=/dev/null bs=1M count=$CONF_READLEN iflag=direct &>/dev/null
}

function update_presence() {
	# no action if no hosts defined
	[ -z "$CONF_HOSTS" ] && return 0

	# assume present if any host is ping'able
	for H in "${CONF_HOSTS[@]}"; do
		if ping -c 1 -q "$H" &>/dev/null; then
			if [ $USER_PRESENT -eq 0 ]; then
				log "active host detected ($H)"
				USER_PRESENT=1
			fi
			return 0
		fi
	done

	# absent
	if [ $USER_PRESENT -eq 1 ]; then
		log "all hosts inactive"
		USER_PRESENT=0
	fi

	return 0
}

function check_dev() {
	# initialize real device name
	DEV="${DEVICES[$1]}"
	if ! [ -e "/dev/$DEV" ]; then
		if [ -L "/dev/disk/by-id/$DEV" ]; then
			DEV="$(basename "$(readlink "/dev/disk/by-id/$DEV")")"
			log "recognized disk: ${DEVICES[$1]} --> $DEV"
			DEVICES[$1]="$DEV"
		else
			log "skipping missing device '$DEV'" >&2
			return 0
		fi
	fi
	
	# initialize r/w timestamp
	[ -z "${STAMP[$1]}" ] && STAMP[$1]=$(date +%s)

	# check for user presence, spin up if required
	if [ $USER_PRESENT -eq 1 ]; then
		dev_isup "$DEV" || dev_spinup "$DEV"
	fi

	# refresh r/w stats
	COUNT_NEW="$(dev_stats "$DEV")"

	# spindown logic if stats equal previous recordings
	if [ "${COUNT[$1]}" == "$COUNT_NEW" ]; then
		# skip spindown if user present
		if [ $USER_PRESENT -eq 0 ]; then
			# check against idle timeout
			if [ $(($(date +%s) - ${STAMP[$1]})) -ge ${TIMEOUT[$1]} ]; then
				# spindown disk
				dev_spindown "$DEV"
			fi
		fi
	else
		# update r/w timestamp
		COUNT[$1]="$COUNT_NEW"
		STAMP[$1]=$(date +%s)
	fi
}


# read config file
if ! [ -r "$CONFIG" ]; then
	echo "error: unable to read config file '$CONFIG', aborting." >&2
	exit 1
else
    source "$CONFIG"
fi

# default watch interval: 300s
readonly CONF_INT=${CONF_INT:-300}
# default spinup read size: 128MiB
readonly CONF_READLEN=${CONF_READLEN:-128}
# default syslog usage: disabled
readonly CONF_SYSLOG=${CONF_SYSLOG:-0}
# default force SATA device type: disabled
readonly CONF_FORCE_SATA=${CONF_FORCE_SATA:-0}

# check prerequisites
check_req date hdparm smartctl dd cut grep
[ -n "$CONF_HOSTS" ] && check_req ping
[ $CONF_SYSLOG -eq 1 ] && check_req logger

# pre-set smartctl call
[ $CONF_FORCE_SATA -eq 1 ] && SMARTCTL=" -d sat"
readonly SMARTCTL="smartctl${SMARTCTL}"

# refuse to work without disks defined
if [ -z "$CONF_DEV" ]; then
	echo "error: missing configuration parameter 'CONF_DEV', aborting." >&2
	exit 1
fi

# initialize device arrays
DEV_MAX=$((${#CONF_DEV[@]} - 1))
for I in $(seq 0 $DEV_MAX); do
	DEVICES[$I]="$(echo "${CONF_DEV[$I]}" | cut -d '|' -f 1)"
	TIMEOUT[$I]="$(echo "${CONF_DEV[$I]}" | cut -d '|' -f 2)"
done


USER_PRESENT=0
log "Using ${CONF_INT}s interval"

while true; do
	update_presence

	for I in $(seq 0 $DEV_MAX); do
		check_dev $I
	done

	sleep $CONF_INT
done
