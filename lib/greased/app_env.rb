module AppEnv
  extend self

  def [](key)
    key = key.to_s.upcase
    ENV[key]
  end

  def fetch(key)
    self[key] or raise(IndexError, "#{key} missing from config", caller)
  end

  def guarded?
    self[:guard_name] && self[:guard_password]
  end

  def requires(*keys)
    keys.each do |key|
      unless self[key]
        raise RuntimeError, "AppEnv[#{key.inspect}] is required but missing", caller
      end
    end
  end

  def url(key)
    URI.parse(fetch("#{key}_url"))
  end

  def background(job, *args)
    if AppEnv[:enable_backgrounding]
      Resque.enqueue(job, *args)
    else
      job.perform(*args)
    end
  end

end
