module SensuPluginsOracle
  class Session

    attr_reader :name, :error_message
    attr_reader :connect_string
    attr_reader :username, :password, :database, :priviledge

    attr_reader :server_version

    PRIVILEDGES = [:SYSDBA, :SYSOPER, :SYSASM, :SYSBACKUP, :SYSDG, :SYSKM]

    def initialize(args)
      @name = args[:name]
      @error_message = nil

      @connect_string = args[:connect_string]

      @username = args[:username]
      @password = args[:password]
      @database = args[:database]
      @priviledge = args[:priviledge].upcase.to_sym if args[:priviledge] && PRIVILEDGES.include?(args[:priviledge].upcase.to_sym)
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
      connection = OCI8.new(@connect_string) if @connect_string
      connection = OCI8.new(@username, @password, @database) if @username

      @server_version = connection.oracle_server_version

      true
    rescue OCIError => e
      @error_message = [@name, e.message.split("\n").first].compact.join(": ")
      false
    ensure
      connection.logoff if connection
    end

  end
end
