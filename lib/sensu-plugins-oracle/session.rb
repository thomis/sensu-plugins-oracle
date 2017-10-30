require 'dentaku'

module SensuPluginsOracle
  # Session to handle oracle checks
  class Session
    attr_reader :name, :error_message
    attr_reader :connect_string
    attr_reader :username, :password, :database, :priviledge

    attr_reader :server_version

    attr_accessor :rows

    PRIVILEDGES = [
      :SYSDBA,
      :SYSOPER,
      :SYSASM,
      :SYSBACKUP,
      :SYSDG,
      :SYSKM
    ].freeze

    # catch any error thrown within a thread during join call
    Thread.abort_on_exception = true

    def initialize(args)
      @name = args[:name]
      @error_message = nil
      @rows = []

      @connect_string = args[:connect_string]

      @username = args[:username]
      @password = args[:password]
      @database = args[:database]
      @priviledge = validate_priviledge(args[:priviledge])
      @provide_name_in_result = args[:provide_name_in_result] || false
    end

    def self.parse_from_file(file)
      sessions = []

      File.open(file) do |input|
        input.each_line do |line|
          line.strip!
          next if line.size.zero? || line =~ /^#/
          a = line.split(/:|,|;/)
          sessions << Session.new(name: a[0],
                                  connect_string: a[1],
                                  provide_name_in_result: true)
        end
      end

      sessions
    end

    def alive?
      connect
      @server_version = @connection.oracle_server_version
      true
    rescue StandardError, OCIError => e
      @error_message = [@name, e.message.split("\n").first].compact.join(': ')
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
      @error_message = [@name, e.message.split("\n").first].compact.join(': ')
      return false
    end

    def handle_query_result(config = {})
      # check if query is ok, warning, or critical
      value = @rows.size
      value = @rows[0][0].to_f if @rows[0] && !config[:tuples]

      method = evaluate(config, value)

      [method, show(config[:show])]
    end

    def self.timeout_properties(timeout)
      return unless timeout
      timeout = timeout.to_i
      OCI8.properties[:tcp_connect_timeout] = timeout
      OCI8.properties[:connect_timeout] = timeout
      OCI8.properties[:send_timeout] = timeout
      OCI8.properties[:recv_timeout] = timeout
    end

    def self.handle_multiple(args = {})
      # queue with sesssion
      queue_sessions = Queue.new

      # feed the queue with sessions
      args[:sessions].map { |session| queue_sessions.push(session) }

      if args[:config][:verbose]
        puts "Worker Threads: #{args[:config][:worker]}"
      end

      # start worker threads and handle requested sessions
      worker = (1..args[:config][:worker]).map do
        Thread.new do
          until queue_sessions.empty?
            session = queue_sessions.pop(true)
            start = Time.now
            message = "Processing #{session.name} - Method: #{args[:method]}"
            puts message if args[:config][:verbose]
            if args[:method_args]
              session.send(args[:method], args[:method_args])
            else
              session.send(args[:method])
            end
            message_done = format('Done       %s, took %0.1f ms',
                                  session.name,
                                  (Time.now - start) * 1000)
            puts message_done if args[:config][:verbose]
          end
        end
      end
      worker.map(&:join)
    end

    private

    def validate_priviledge(priviledge)
      return nil unless priviledge
      priviledge_symbol = priviledge.upcase.to_sym
      return nil unless PRIVILEDGES.include?(priviledge_symbol)
      priviledge_symbol
    end

    def show(show_records = true)
      return nil unless show_records
      buffer = []
      buffer << "#{@name} (#{@rows.size})" if @provide_name_in_result
      buffer += @rows.map { |row| '- ' + row.join(', ') }
      buffer.join("\n")
    end

    def evaluate(config, value)
      calc = Dentaku::Calculator.new

      method = :ok

      if config[:warning] && calc.evaluate(config[:warning], value: value)
        method = :warning
      end

      if config[:critical] && calc.evaluate(config[:critical], value: value)
        method = :critical
      end

      method
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
