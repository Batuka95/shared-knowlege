
eventsfile="/data/local/tmp/eventsbl28"
if test -f $eventsfile; then
echo 
else
    echo "events FILE exists."
	exit
fi




orx=$(($1 * 255/10))
ory=$(($2 * 455/10))
#echo "x = $1 y = $2"
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
#echo "####################"
#echo "$eventsfile"
#echo "x \x${x:2:2}\x${x:0:2}"
#echo "y \x${y:2:2}\x${y:0:2}"
#echo "####################"
printf "\x${x:2:2}\x${x:0:2}" | busybox dd of=$eventsfile bs=1 seek=20 count=2 conv=notrunc		> /dev/null 2>&1
printf "\x${x:2:2}\x${x:0:2}" | busybox dd of=$eventsfile bs=1 seek=116 count=2 conv=notrunc 	> /dev/null 2>&1

#printf "\xFB\xFA" | busybox dd of=$eventsfile bs=1 seek=20 count=2 conv=notrunc
#printf "\xFB\xFA" | busybox dd of=$eventsfile bs=1 seek=116 count=2 conv=notrunc
#echo "x ${x:2:2}${x:0:2}"
#echo "y ${y:2:2}${y:0:2}"
printf "\x${y:2:2}\x${y:0:2}" | busybox dd of=$eventsfile bs=1 seek=44 count=2 conv=notrunc 	> /dev/null 2>&1
printf "\x${y:2:2}\x${y:0:2}" | busybox dd of=$eventsfile bs=1 seek=140 count=2 conv=notrunc    > /dev/null 2>&1

#printf "\x$(printf '%02x' $1)" | dd of=events bs=1 seek=12 count=2 conv=notrunc status=none
#printf '%x' $2 | dd of=events bs=1 seek=28 count=2 conv=notrunc status=none

#printf '%04x\n' $2 | dd of=events bs=1 seek=28 count=2 conv=notrunc
#printf '\xff\xff' | dd of=events bs=1 seek=28 count=2 conv=notrunc

#hexdump $eventsfile
#cat $eventsfile > /dev/input/event5
#
busybox dd bs=1600 if=$eventsfile of=/dev/input/event4 > /dev/null 2>&1
echo "done"
