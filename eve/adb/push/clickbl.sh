#OnePlus5:/data/local/tmp $ while true ; do sh eve.sh $( nc -lp 26000) ; done
#netcat -lp 26000 | while read line; do echo $line; done
#adb -s emulator-5584 forward tcp:26000 tcp:26000
#rm events && cat /dev/input/event5 > events
eventsfile="/data/local/tmp/eventsbl"
if test -f $eventsfile; then
echo 
else
    echo "events FILE exists."
	exit
fi




orx=$(($1 * 255/10))
ory=$(($2 * 455/10))
echo "x = $1 y = $2"
#echo "x = $orx y = $ory"

x=$(printf '%02x' $orx)
y=$(printf '%02x' $ory)

#echo "X dec=$1:hex=$x len: ${#x}" 
#echo "Y dec=$2:hex=$y len: ${#y}"

if (( ${#x}>3 ))
then
#echo "x4"
# echo "First 2:${x:0:2}"
# echo "Second 2:${x:2:2}"
 echo
 
else

if (( ${#x}>2 ))
then
x=0$x
# echo "x3"
# echo "First 2:${x:0:2}"
# echo "Second 2:${x:2:2}"
 
 
else
x=00$x
# echo "x2"
# echo "First 2:${x:0:2}"
# echo "Second 2:${x:2:2}"
 

 
fi

# echo "fail"
fi


if (( ${#y}>3 ))
then
# echo "First 2:${y:0:2}"
# echo "Second 2:${y:2:2}"
 
 echo
else

if (( ${#y}>2 ))
then
y=0$y
 
# echo "First 2:${y:0:2}"
# echo "Second 2:${y:2:2}"
 
 
else
y=00$y
 
# echo "First 2:${y:0:2}"
#echo "Second 2:${y:2:2}"
 

 
fi

# echo "fail"
fi

#echo "x ${x:2:2}${x:0:2}"
printf "\x${x:2:2}\x${x:0:2}" | dd of=$eventsfile bs=1 seek=12 count=2 conv=notrunc status=none
printf "\x${x:2:2}\x${x:0:2}" | dd of=$eventsfile bs=1 seek=76 count=2 conv=notrunc status=none
#echo "y ${y:2:2}${y:0:2}"
printf "\x${y:2:2}\x${y:0:2}" | dd of=$eventsfile bs=1 seek=28 count=2 conv=notrunc status=none
printf "\x${y:2:2}\x${y:0:2}" | dd of=$eventsfile bs=1 seek=92 count=2 conv=notrunc status=none

#printf "\x$(printf '%02x' $1)" | dd of=events bs=1 seek=12 count=2 conv=notrunc status=none
#printf '%x' $2 | dd of=events bs=1 seek=28 count=2 conv=notrunc status=none

#printf '%04x\n' $2 | dd of=events bs=1 seek=28 count=2 conv=notrunc
#printf '\xff\xff' | dd of=events bs=1 seek=28 count=2 conv=notrunc

#hexdump $eventsfile
cat $eventsfile > /dev/input/event5

echo "done"
