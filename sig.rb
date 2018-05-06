TAU = Math::PI * 2

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

  def clip(level=1.0)
    level = Sig.of(level)
    self.class.new do |t|
      max = level[t]
      min = -max
      s = sample(t)
      next min if s < min
      next max if s > max
      s
    end
  end

  def bit_sample(t)
    [(clip.sample(t) * 0x7fff).round].pack("s<")
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

  def mix(other, amt=0)
    amt = Sig.of(amt)
    self.class.new do |t|
      first  = ((1.0 - amt[t]) / 2.0) * sample(t)
      second = ((1.0 + amt[t]) / 2.0) * other.sample(t)
      first + second
    end
  end

  def fm(other, amt=1, freq=2)
    amt_s = Sig.of(amt)
    freq_s = Sig.of(freq)

    shift(other.pitch(freq).vol(amt))
  end

  def pitch(p)
    p = Sig.of(p)
    Sig.new do |t|
      sample(p[t] * t)
    end
    # mod { |t| t * p_s[t] }
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

  def unsign
    map { |x| (x + 1) / 2 }
  end

  def sign
    map { |x| x * 2 - 1 }
  end

  def shift(amt)
    amt_s = Sig.of(amt)
    mod { |t| t + amt[t] }
  end

  def loop(period=1)
    mod { |x| x % period }
  end

  def samples(rate, seconds=2, &b)
    return enum_for(:samples, rate, seconds).to_a unless block_given?

    (0..(rate * seconds)).each do |i|
      yield sample(i.to_f / rate)
    end
  end

  def inspect(rate=10, range=4)
    levels = samples(10).map { |x| (x * range).round }
    "#<Sig\n#{(-range..range).map do |i|
      levels.map { |l| l == i ? "*" : " " }.join('')
    end.reverse.join("\n")}>"
  end

  def bytes(*a)
    clip.samples(*a) { |x| yield [(x * 0x7fff).round].pack("s<") }
  end
end
