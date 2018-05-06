fm.wav: ./fm.raw
	sox -r 48k -e signed -L -b 16 -c 1 $^ $@

fm.raw: ./wave.rb
	ruby -r ./wave.rb -e main > $@
