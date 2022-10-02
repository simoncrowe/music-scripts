#! /bin/sh


device="hw:0"
while getopts "d:" opt; do
	case $opt in
		d)
			device=$OPTARG;;
		\?)
			echo "Invald option: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argment." >&2
			exit 1
			;;
	esac
done

echo "Starting JACK with device: $device"
jackd -r -d alsa -r 44100	-d $device &

sclang `dirname "$0"`/start-superdirt.scd
