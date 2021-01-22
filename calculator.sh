#! /bin/sh -
#
# This is the script that sets the level of niceness to run the
# 'slave'-program at, and runs it.


ARC=`uname`

if [ -r slave-$ARC ]
then
#	rm -f slave_output.dat
#	rm -f slave_stats.dat
#	exec nice -10 ./slave-$ARC
echo ho
else 
	echo "Unknown platform"
fi
