# An FM Synthesizer!

Edit `wave.rb` and run `make` - whatever the `Wave#wave` method returns will be generated as a .wav file. Requires `sox` (likely available in homebrew or pacman or your local package manager).

### Examples:

* A bell:

``` ruby
sin.shift(sin.pitch(11).vol(falloff(4)))
```

* A distorted pad

``` ruby
sqr.mod { |x| 2 * Math.exp(x % 2) - 1 }
```

* Maybe a nice bass?

``` ruby
saw.shift(saw.pitch(1.5).vol(falloff))
```

* A crunchy hi-hat or snare

``` ruby
nse.vol(sqr.pitch(4).unsign).vol(falloff.pitch(15)).vol(6)
```

