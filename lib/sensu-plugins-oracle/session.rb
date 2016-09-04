module SensuPluginsOracle
  class Session

    attr_reader :name, :connect_string, :error_message

    def initialize(args)
      @name = args[:name]
      @connect_string = args[:connect_string]
      @error_message = nil
    end

    def self.parse_from_file(file)
      sessions = []

      File.open(file) do |input|
        input.each_line do |line|
          line.strip!
          next if line.size == 0 || line =~ /^#/
          a = line.split(/:|,|;/)
          sessions << Session.new(name: a[0], connect_string: a[1])
        end
      end

      return sessions
    end

    def alive?
      connection = OCI8.new(@connect_string)
      true
    rescue OCIError => e
      @error_message = [@name, e.message.split("\n").first].compact.join(": ")
      false
    ensure
      connection.logoff if connection
    end

  end
end
