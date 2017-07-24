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
#   ./check-oracle-alive.rb -u USERNAME -p PASSWORD -d DATABASE -P PRIVILEGE -T TIMEOUT -f FILE
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
         description: 'Connect to Oracle database by optional priviledge (SYSDBA, SYSOPER, SYSASM,  , SYSDG or SYSKM)',
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

  def run
    # handle OCI8 properties
    ::SensuPluginsOracle::Session.set_timeout_properties(config[:timeout])

    if config[:file]
      handle_connections_from_file
    else
      handle_connection
    end
  end

  private

  def handle_connections_from_file
    sessions = ::SensuPluginsOracle::Session.parse_from_file(config[:file])

    sessions_total = sessions.size
    sessions_alive = 0

    thread_group = ThreadGroup.new
    queue = Queue.new
    mutex = Mutex.new

    sessions.each do |session|
      thread_group.add Thread.new {
        if session.alive?
          mutex.synchronize do
            sessions_alive += 1
          end
        else
          queue << session.error_message
        end
      }
    end
    thread_group.list.map(&:join)
    sessions_critical = queue.size.times.map { queue.pop }

    if sessions_total == sessions_alive
      ok "All are alive (#{sessions_alive}/#{sessions_total})"
    else
      critical ["#{sessions_alive}/#{sessions_total} are alive", sessions_critical].flatten.join("\n - ")
    end
  rescue => e
    unknown e.to_s
  end

  def handle_connection
    session = SensuPluginsOracle::Session.new(
      username: config[:username],
      password: config[:password],
      database: config[:database],
      privilege: config[:privilege])

    if session.alive?
      ok "Server version: #{session.server_version}"
    else
      critical session.error_message
    end
  end
end
