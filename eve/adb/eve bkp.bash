#rm events && cat /dev/input/event5 > events
#orx=$(($1*27))
#ory=$(($2*45))

x=$(printf '%02x' $1)
y=$(printf '%02x' $2)

echo "X dec=$1:hex=$x len: ${#x}" 
echo "Y dec=$2:hex=$y len: ${#y}"

if (( ${#x}>3 ))
then
echo "x4"
 echo "First 2:${x:0:2}"
 echo "Second 2:${x:2:2}"
 
 
else

if (( ${#x}>2 ))
then
x=0$x
 echo "x3"
 echo "First 2:${x:0:2}"
 echo "Second 2:${x:2:2}"
 
 
else
x=00$x
 echo "x2"
 echo "First 2:${x:0:2}"
 echo "Second 2:${x:2:2}"
 

 
fi

 echo "fail"
fi


if (( ${#y}>3 ))
then
 echo "First 2:${y:0:2}"
 echo "Second 2:${y:2:2}"
 
 
else

if (( ${#y}>2 ))
then
y=0$y
 
 echo "First 2:${y:0:2}"
 echo "Second 2:${y:2:2}"
 
 
else
y=00$y
 
 echo "First 2:${y:0:2}"
 echo "Second 2:${y:2:2}"
 

 
fi

 echo "fail"
fi

echo "x ${x:2:2}${x:0:2}"
printf "\x${x:2:2}\x${x:0:2}" | dd of=events bs=1 seek=12 count=2 conv=notrunc status=none
printf "\x${x:2:2}\x${x:0:2}" | dd of=events bs=1 seek=76 count=2 conv=notrunc status=none
echo "y ${y:2:2}${y:0:2}"
printf "\y${y:2:2}\y${y:0:2}" | dd of=events bs=1 seek=28 count=2 conv=notrunc status=none
printf "\y${y:2:2}\y${y:0:2}" | dd of=events bs=1 seek=92 count=2 conv=notrunc status=none

#printf "\x$(printf '%02x' $1)" | dd of=events bs=1 seek=12 count=2 conv=notrunc status=none
#printf '%x' $2 | dd of=events bs=1 seek=28 count=2 conv=notrunc status=none

#printf '%04x\n' $2 | dd of=events bs=1 seek=28 count=2 conv=notrunc
#printf '\xff\xff' | dd of=events bs=1 seek=28 count=2 conv=notrunc

hexdump events
cat events > /dev/input/event5
#sendevent /dev/input/event5 3 57 0
#sendevent /dev/input/event5 3 53 112
#sendevent /dev/input/event5 3 54 358
#sendevent /dev/input/event5 3 48 1
#sendevent /dev/input/event5 3 58 1
#sendevent /dev/input/event5 0 2 0
#sendevent /dev/input/event5 0 0 0
#sendevent /dev/input/event5 3 57 -1
#sendevent /dev/input/event5 0 2 0
#sendevent /dev/input/event5 0 0 0
#