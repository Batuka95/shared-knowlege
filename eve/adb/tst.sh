#while true; do sh eve.sh $( nc -lp 80808); done
sh eve.sh $( nc -lp 8080) && echo "done" | nc -lp 8080


#    netcat -lk -p 12345 | while read line
#    do
#        match=$(echo $line | grep -c 'Keep-Alive')
#        if [ $match -eq 1 ]; then
#            echo "Here run whatever you want..."
#        fi
#    done
#	 while read line; do echo $line; done < $(netcat -lp 26001)