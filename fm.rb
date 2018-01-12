# require 'math'
TAU = Math::PI * 2
RATE = 44000.0

# MAX_16BIT

class Sig
  def initialize(&signal)
    raise 'uh' if signal.nil?
    @signal = signal
  end

  def sample(t)
    out = @signal.call(t)
  end

  def [](t)
    sample(t)
  end

  def clip(t)
    x = sample(t)
    return -1 if x < -1
    return 1 if x > 1
    x
  end

  def bit_sample(t)
    [(clip(t) * 0x7fff).round].pack("s<")
  end

  def map(&b)
    self.class.new { |t| b.call(sample(t)) }
  end

  def mod(&b)
    self.class.new { |t| sample(b.call(t)) }
  end

  def self.of(o)
    case o
    when Sig then o
    when Numeric then new { |_| o }
    end
  end

  def mix(other, amt=0.5)
    self.class.new { |t| amt * sample(t) + (1 - amt) * other.sample(t) }
  end

  def fm(other, amt=1, freq=2)
    amt_s = Sig.of(amt)
    freq_s = Sig.of(freq)

    shift(other.pitch(freq).vol(amt))
  end

  def pitch(p)
    p_s = Sig.of(p)
    mod { |t| t * p_s[t] }
  end

  def vol(v)
    v_s = Sig.of(v)
    self.class.new { |t| sample(t) * v_s[t] }
  end

  def inv
    map { |x| -x }
  end

  def rev
    mod { |t| -t }
  end

  def shift(amt)
    amt_s = Sig.of(amt)
    mod { |t| t + amt[t] }
  end

  def samples(rate, seconds=2, &b)
    return enum_for(:samples, rate, seconds).to_a unless block_given?

    (0..(rate * seconds)).each do |i|
      yield clip(i.to_f / rate)
    end
  end

  def inspect(rate=10, range=4)
    levels = samples(10).map { |x| (x * range).round }
    "#<Sig\n#{(-range..range).map do |i|
      levels.map { |l| l == i ? "*" : " " }.join('')
    end.reverse.join("\n")}>"
  end

  def bytes(*a)
    samples(*a) { |x| yield [(x * 0x7fff).round].pack("s<") }
  end
end

module Wave
  def sin; Sig.new { |t| Math.sin (2 * Math::PI * t) } end
  def sqr; Sig.new { |t| t < 0.01 ? 0 : (t * 2).round % 2 == 0 ? 1 : -1 } end
  def saw; Sig.new { |t| ((t % 1) * 2 - 1) } end
  def tri; saw.map { |s| s.abs * 2 - 1 } end
  def exp; Sig.new { |t| Math.exp t }; end

  def wave
    falloff = Sig.new { |t| t /= 440; 1.8 * 0.3 * Math.exp(-2 * t) * Math.sqrt(t + 0.2) }

    hard = sin.fm(sin, exp.pitch(0.008), 3.0).vol(falloff.pitch(2))

    # sin.fm(hard, 0.4, 2).vol(falloff)
  end
end

# def old
#   def wave(t)
#     note = 440
#     amount = 1.8 * 0.4 * exp(-2 * t) * Math.sqrt(t) * sn(0.8 * t)
#     return sq(note * t + amount * sw(note * 7 * t))
#   end
# end

def main
  include Wave
  wave.pitch(440).bytes(44000, 4) { |s| print s }
end
