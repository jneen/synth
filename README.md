# A Mono FM Synthesizer!

Requirements:
  * sox
  * mplayer
  * ruby

Usage:
  * open console with `make c`
  * type expressions (look at `wave.rb` for some of the stuff available)
  * `r <filename>, <expr>` renders an expression into a file
  * `a <expr>` auditions the expression with mplayer
  * `i <expr>` attempts to show the shape of the wave in the terminal

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

