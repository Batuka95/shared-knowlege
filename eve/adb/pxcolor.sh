widthheight=$(wm size | sed "s/.* //")
width=$(($(echo $widthheight | sed "s/x.*//g" )+0))
height=$(($(echo $widthheight | sed "s/.*x//g" )+0))
GetColorAtPixel () {
	x=$1;y=$2;
	rm ./screen.dump 2> /dev/null
	screencap screen.dump
	screenshot_size=$(($(wc -c < ./screen.dump)+0));
	buffer_size=$(($screenshot_size/($width*height)))
	let offset=$width*$y+$x+3
	color=$(dd if="screen.dump" bs=$buffer_size count=1 skip=$offset 2>/dev/null | hexdump | grep -Eo "([0-9A-F]{2} )" |sed "s/[^0-9A-F]*\$//g" | sed ':a;N;$!ba;s/\n//g' |cut -c3-8)
	echo $color;
}

GetColorAtPixel2 () {
        x=$1;y=$2;
        rm ./screen.dump 2> /dev/null
        screencap screen.dump
        screenshot_size=$(($(wc -c < ./screen.dump)+0));
        buffer_size=$(($screenshot_size/($width*height)))
        let offset=$width*$y+$x+3

        color=$(dd if="screen.dump" bs=$buffer_size count=1 skip=$offset 2>/dev/null | hexdump | awk '{ print toupper($0) }' | grep -Eo "([0-9A-F]{2})+" | sed ':a;N;$!ba;s/\n//g' | cut -c9-14 )
        echo $color;
}
GetColorAtPixel2 $1 $2