#!/bin/sh
# script for waking up on lan
#MAC Address to wake up
Identifier="tsl-bew-srv-apc1 1600"
MinBatt="50.0"
MAC_ADDR="94:18:82:8A:F3:F4"
IP="192.168.1.2"
WOL="/usr/bin/wakeonlan"	# apt-get install wakeonlan
apcaccess > temp.txt

#extract line from temp.txt with BCHARGE in it
FirstBatExtract=$(grep -n "BCHARGE" temp.txt)
#cleanup so we only have the float value
FinalBatExtract=$(echo "$FirstBatExtract" | awk -F' ' '{print $3}')

echo $FinalBatExtract


ping -q -c5 $IP > /dev/null
 
if [ $? -eq 0 ]
then
	echo $(date '+%d/%m/%Y %H:%M:%S') "ok"

else


if ! awk "BEGIN{ exit ($FinalBatExtract > $MinBatt) }"
then
    $WOL "$MAC_ADDR"
fi

if ! awk "BEGIN{ exit ($FinalBatExtract < $MinBatt) }"
then
    echo $(date '+%d/%m/%Y %H:%M:%S') "WARNING! $Identifier battery is currently at $FinalBatExtract % which is below the specifiec value of $MinBatt %" >> "/home/pi/Desktop/WOL.events" | mail -s "WARNING! $Identifier battery is currently at $FinalBatExtract % which is below the specifiec value of $MinBatt %" support@innovateit.co.mz
fi

fi
