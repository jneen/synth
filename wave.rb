require_relative 'sig'
TAU = Math::PI * 2

module Wave
  PITCH = 440
  VOL = 0.6

  # NB: if you change the rate please also change the sox invocation
  # in the Makefile
  RATE = 48000

  SECONDS = 4

  def sin; Sig.new { |t| Math.sin (2 * Math::PI * t) } end
  def sqr; Sig.new { |t| t < 0.01 ? 0 : (t * 2).round % 2 == 0 ? 1 : -1 } end
  def saw; Sig.new { |t| ((t % 1) * 2 - 1) } end
  def tri; saw.map { |s| s.abs * 2 - 1 } end
  def nse; Sig.new { rand }.sign; end


  def exp(m=1); Sig.new { |t| Math.exp(m * t) }; end

  def falloff(speed=2)
    Sig.new do |t|
      t /= 440
      Math.exp(-speed * t) * Math.sqrt(t + 0.2)
    end
  end

  def attack
    nse.vol(falloff.inv.pitch(4))
  end

  def kick
    sin.shift(sin.pitch(0.25)).pitch(exp(-0.1)).mix(attack, -0.7)
  end

  def bubbles(sig=nil, amt=nil)
    sig ||= sin
    amt ||= 1
    sig.shift(exp.loop(2).sign.vol(amt))
  end

  def royksopp
    sqr.vol(saw.pitch(0.5).unsign)
  end

  def bell
    sin.shift(sin.pitch(11).vol(falloff).vol(0.4))
  end

  # -----> EDIT HERE <------- #
  def wave
    bell.mix(saw, saw.pitch(0.505))
  end

  def renderer
    Renderer.new(RATE, SECONDS) { |w| w.pitch(PITCH).vol(VOL) }
  end

  def render(fname, sig)
    renderer.render(fname, sig)
  end

  def r(fname, sig)
    render(fname, sig)
  end

  def audition(sig)
    renderer.audition(sig)
  end

  def a(sig)
    renderer.audition(sig)
  end
end

def main
  include Wave
  wave.pitch(PITCH).vol(VOL).bytes(RATE, SECONDS) { |s| print s }
end
