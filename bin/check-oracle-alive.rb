#! /usr/bin/env ruby
#
#   check-oracle-alive
#
# DESCRIPTION:
#
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
#   ./check-oracle-alive.rb -u db_user -p db_pass -h db_host -d db
#
# NOTES:
#
# LICENSE:
#   Copyright (c) 2016 Thomas Steiner
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'oci8'

class CheckOracle < Sensu::Plugin::Check::CLI
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
         description: 'Connect to Oracle database by optional priviledge (:SYSDBA, :SYSOPER, :SYSASM, :SYSBACKUP, :SYSDG or :SYSKM)',
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

    if config[:file]
      handle_file
    else
      handle_single_connection
    end

  end

  private

  def handle_file
    unknown 'Not yet implemented'
  end

  def handle_single_connection
    OCI8.properties[:connect_timeout] = config[:timeout].to_i if config[:timeout]

    connection = OCI8.new(config[:username], config[:password], config[:database], config[:privilege])

    ok "Server version: #{connection.oracle_server_version}"
  rescue OCIError => e
    critical "#{e.message.split("\n").first}"
  ensure
    connection.logoff if connection
  end
end
