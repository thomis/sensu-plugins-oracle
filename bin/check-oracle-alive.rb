#! /usr/bin/env ruby
#
#   check-oracle-alive
#
# DESCRIPTION:
#   This plugin attempts to login to oracle with provided credentials.
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
#   ./check-oracle-alive.rb -u USERNAME -p PASSWORD -d DATABASE \
#       -P PRIVILEGE -T TIMEOUT -f FILE
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

# Check Oracle Alive
class CheckOracleAlive < Sensu::Plugin::Check::CLI
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

  option :worker,
         description: 'Number of worker threads to check' \
                      ' for alive connections',
         short: '-W WORKER',
         long: '--worker WORKER',
         default: 1,
         proc: proc { |v| v.to_i.zero? ? 1 : v.to_i }

  option :limit,
         description: 'Limits output size in characters',
         short: '-l SIZE',
         long: '--limit SIZE',
         default: nil

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
      ok("Version #{SensuPluginsOracle::VERSION}")
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
    session = SensuPluginsOracle::Session.new(username: config[:username],
                                              password: config[:password],
                                              database: config[:database],
                                              privilege: config[:privilege])

    if session.alive?
      ok "Server version: #{session.server_version}"
    else
      critical limit(session.error_message)
    end
  end

  def handle_connections_from_file
    sessions = ::SensuPluginsOracle::Session.parse_from_file(config[:file])
    ::SensuPluginsOracle::Session.handle_multiple(sessions: sessions,
                                                  method: :alive?,
                                                  config: config)

    errors = []
    sessions.each do |session|
      message = session.error_message
      errors << message if message
    end

    sessions_total = sessions.size
    errors_total = errors.size

    if errors_total.zero?
      ok "All are alive (#{sessions_total}/#{sessions_total})"
    else
      message = "#{sessions_total - errors_total}/#{sessions_total} are alive"
      critical(limit([message, errors].flatten.join("\n - ")))
    end

  rescue => e
    unknown limit(e.to_s)
  end

  def limit(message)
    return message if config[:limit].nil?
    message[0..config[:limit].to_i]
  end
end
