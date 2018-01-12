fm.wav: ./fm.raw
	sox -r 44k -e signed -L -b 16 -c 1 $^ $@

fm.raw: ./fm.rb
	ruby -r ./fm.rb -e main > $@
