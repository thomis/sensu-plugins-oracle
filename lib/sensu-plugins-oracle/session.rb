require 'dentaku'

module SensuPluginsOracle
  class Session

    attr_reader :name, :error_message
    attr_reader :connect_string
    attr_reader :username, :password, :database, :priviledge

    attr_reader :server_version

    attr_accessor :rows

    PRIVILEDGES = [:SYSDBA, :SYSOPER, :SYSASM, :SYSBACKUP, :SYSDG, :SYSKM]

    def initialize(args)
      @name = args[:name]
      @error_message = nil
      @rows = []

      @connect_string = args[:connect_string]

      @username = args[:username]
      @password = args[:password]
      @database = args[:database]
      @priviledge = args[:priviledge].upcase.to_sym if args[:priviledge] && PRIVILEDGES.include?(args[:priviledge].upcase.to_sym)

      @provide_name_in_result = args[:provide_name_in_result] || false
    end

    def self.parse_from_file(file)
      sessions = []

      File.open(file) do |input|
        input.each_line do |line|
          line.strip!
          next if line.size == 0 || line =~ /^#/
          a = line.split(/:|,|;/)
          sessions << Session.new(name: a[0], connect_string: a[1], provide_name_in_result: true)
        end
      end

      return sessions
    end

    def alive?
      connect
      @server_version = @connection.oracle_server_version
      true
    rescue StandardError, OCIError => e
      @error_message = [@name, e.message.split("\n").first].compact.join(": ")
      false
    ensure
      disconnect
    end

    def query(query_string)
      connect
      @rows = []

      cursor = @connection.exec(query_string)

      @rows = []
      while (row = cursor.fetch)
        @rows << row
      end
      cursor.close

      return true
    rescue StandardError, OCIError => e
      @error_message = [@name, e.message.split("\n").first].compact.join(": ")
      return false
    end

    def handle_query_result(config={})
      # check if query is ok, warning, or critical
      value = @rows.size
      value = @rows[0][0].to_f if @rows[0] && !config[:tuples]

      calc = Dentaku::Calculator.new

      case
      when config[:critical] && calc.evaluate(config[:critical], value: value)
        return :critical, show(config[:show])
      when config[:warning] && calc.evaluate(config[:warning], value: value)
        return :warning, show(config[:show])
      else
        return :ok, show(config[:show])
      end
    end

    private

    def show(show_records=true)
      return nil unless show_records
      buffer = []
      buffer << "#{@name} (#{@rows.size})" if @provide_name_in_result
      buffer += @rows.map{ |row| '- ' + row.join(', ')}
      buffer.join("\n")
    end

    def connect
      return if @connection

      if @username
        @connection = OCI8.new(@username.to_s, @password.to_s, @database.to_s)
      else
        @connection = OCI8.new(@connect_string.to_s)
      end
    end

    def disconnect
      @connection.logoff if @connection
      @connection = nil
    end

  end
end
