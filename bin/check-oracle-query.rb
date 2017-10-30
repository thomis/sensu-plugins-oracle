#! /usr/bin/env ruby
#
#   check-oracle-query
#
# DESCRIPTION:
#   This plugin attempts to execute defined query against provided
#   connection credential(s).
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: ruby-oci8
#
# USAGE:
#   ./check-oracle-query.rb -u USERNAME -p PASSWORD -d DATABASE \
#                           -P PRIVILEGE -T TIMEOUT -f FILE \
#                           -q 'select foo from bar' \
#                           -w 'value > 5' -c 'value > 10'
#
# NOTES:
#
# LICENSE:
#   Copyright (c) 2016 Thomas Steiner
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugins-oracle'
require 'sensu-plugin/check/cli'

# Check Oracle Query
class CheckOracleQuery < Sensu::Plugin::Check::CLI
  option :username,
         description: 'Oracle Username',
         short: '-u USERNAME',
         long: '--username USERNAME'

  option :password,
         description: 'Oracle Password',
         short: '-p PASSWORD',
         long: '--password PASSWORD'

  option :database,
         description: 'Database schema to connect to',
         short: '-d DATABASE',
         long: '--database DATABASE'

  option :privilege,
         description: 'Connect to Oracle database by optional priviledge' \
                      ' (SYSDBA, SYSOPER, SYSASM,  , SYSDG or SYSKM)',
         short: '-P PRIVILEGE',
         long: '--privilege PRIVILEGE'

  option :timeout,
         description: 'Connection timeout (seconds)',
         short: '-T TIMEOUT',
         long: '--timeout TIMEOUT'

  option :file,
         description: 'File with connection strings to check',
         short: '-f FILE',
         long: '--file FILE'

  option :query,
         description: 'Database query to execute',
         short: '-q QUERY',
         long: '--query QUERY',
         required: true

  option :warning,
         description: 'Warning threshold expression',
         short: '-w WARNING',
         long: '--warning WARNING',
         default: nil

  option :critical,
         description: 'Critical threshold expression',
         short: '-c CRITICAL',
         long: '--critical CRITICAL',
         default: nil

  option :tuples,
         description: 'Count the number of tuples (rows) returned by the query',
         short: '-t',
         long: '--tuples',
         boolean: true,
         default: false

  option :show,
         description: 'Show result records',
         short: '-s',
         long: '--show',
         boolean: true,
         default: false

  option :worker,
         description: 'Number of worker threads to execute query' \
                      ' against provided connections',
         short: '-W WORKER',
         long: '--worker WORKER',
         default: 1,
         proc: proc { |v| v.to_i.zero? ? 1 : v.to_i }

  option :verbose,
         description: 'Shows console log messages',
         short: '-V',
         long: '--verbose',
         boolean: true,
         default: false

  option :version,
         description: 'Shows current version',
         short: '-v',
         long: '--version',
         boolean: true,
         default: false

  def run
    # handle OCI8 properties
    ::SensuPluginsOracle::Session.timeout_properties(config[:timeout])

    if config[:version]
      ok("Version #{SensuPluginsOracle::Version::VER_STRING}")
      return
    end

    if config[:file]
      handle_connections_from_file
    else
      handle_connection
    end
  end

  private

  def handle_connection
    session = SensuPluginsOracle::Session.new(
      username: config[:username],
      password: config[:password],
      database: config[:database],
      privilege: config[:privilege]
    )

    if session.query(config[:query].to_s)
      method, message = session.handle_query_result(config)
      send(method, message)
    else
      # issue with the query
      critical session.error_message
    end
  end

  def handle_connections_from_file
    sessions = ::SensuPluginsOracle::Session.parse_from_file(config[:file])
    ::SensuPluginsOracle::Session.handle_multiple(sessions: sessions,
                                                  method: :query,
                                                  config: config,
                                                  method_args: config[:query])

    results = Hash.new { |h, key| h[key] = [] }
    sessions.each do |session|
      message = session.error_message
      if message
        results[:critical] << message
      else
        type, message = session.handle_query_result(config)
        results[type] << message
      end
    end

    method, messages = summary(results, sessions.size)

    send(method, messages.join("\n"))
  rescue => e
    unknown e.to_s
  end

  # returns summary based on header and detailed (warning & critical) messages
  def summary(results, session_count)
    # header
    method = :ok
    header = ["Total: #{session_count}"]
    messages = []

    [:ok, :warning, :critical].each do |type|
      next if results[type].empty?
      header << format('%s: %d', type.to_s.capitalize, results[type].size)

      next if type == :ok

      method = type
      messages << nil
      messages << type.to_s.capitalize
      messages << results[type].compact.sort.join("\n\n")
    end
    [method, [header.join(', '), messages]]
  end
end
