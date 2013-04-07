module Env
  extend self

  def [](key)
    fetch(key)
  end

  def fetch(key)
    ENV[format_key(key)] || raise(IndexError, "#{key} missing from config", caller)
  end

  # def guarded?
    # self[:guard_name] && self[:guard_password]
  # end

  def requires(*keys)
    keys.each do |key|
      raise(RuntimeError, "AppEnv[#{key.inspect}] is required but missing", caller) unless self[key]
    end
    nil
  end

  # def background(job, *args)
    # if self[:enable_backgrounding]
      # Resque.enqueue(job, *args)
    # else
      # job.perform(*args)
    # end
  # end
  
  private
  
  def format_key(key)
    key.to_s.upcase
  end

end
