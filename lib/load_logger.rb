class LoadLogger
  LOG_PREFIXES = {
    info:  "INFO:    ",
    warn:  "WARNING: ",
    debug: "DEBUG:   ",
  }

  Message = Struct.new('Message', :severity, :text) do
    def print
      prefix = LOG_PREFIXES.fetch(severity)
      puts "#{prefix}#{text}"  
    end
  end

  def initialize
    @messages = []
  end

  # Create a new 'current logger', run a block, and return the logger to capture any messages it
  # logged.
  # @return [LoadLogger]
  def self.collect
    logger = new
    self.current = logger
    yield
    logger
  ensure
    self.current = nil
  end

  class << self
    # @return [LoadLogger] The current logger.
    attr_accessor :current
  end

  # @return [<Message>] The messages which have been logged by this logger.
  attr_reader :messages

  # Count the number of messages logged of each severity.
  # @return [{ Symbol => Integer }]
  def count_message_severities
    counts = LOG_PREFIXES
      .keys
      .map { |sev| [sev, 0] }
      .to_h
    messages.each do |msg|
      counts[msg.severity] += 1
    end
    counts
  end

  def debug(text) = log(:debug, text)
  def info(text)  = log(:info, text)
  def warn(text)  = log(:warn, text)

  def self.debug(*) = current.debug(*)
  def self.info(*)  = current.info(*)
  def self.warn(*)  = current.warn(*)

  private def log(severity, text)
    msg = Message.new(severity, text)
    msg.print
    messages << msg
  end
end
