
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-oracle.svg)](https://badge.fury.io/rb/sensu-plugins-oracle)
[![01 - Test](https://github.com/thomis/sensu-plugins-oracle/actions/workflows/01_test.yml/badge.svg)](https://github.com/thomis/sensu-plugins-oracle/actions/workflows/01_test.yml)
[![02 - Release](https://github.com/thomis/sensu-plugins-oracle/actions/workflows/02_release.yml/badge.svg)](https://github.com/thomis/sensu-plugins-oracle/actions/workflows/02_release.yml)

# sensu-plugins-oracle

This sensu plugin provides native Oracle instrumentation.

## Files
  * bin/check-oracle-alive.rb
  * bin/check-oracle-query.rb

## Usage

  ```
  -- check a single connection
  check-oracle-alive.rb -u scott -p tiger -d hr

  -- check a single connection with timeout
  check-oracle-alive.rb -u scott -p tiger -d hr -T 30
  ```

  ```
  -- check multiple connections as defined in a file, use 5 worker threads (-W 5) and verbose output (-v)
  check-oracle-alive.rb -f connections.csv -W 5 -v

  > cat connections.csv
    # production connection
    example_connection_1,scott/tiger@hr

    # test connection
    example_connection_2,scott/tiger@hr_test
  ```

  ```
  -- check for invalid objects in a schema, shows type and name if there are invalid objects (-s), define a ciritical boundary only (-c)
  check-oracle-query.rb -u scott -p tiger -d hr -t -s -query "select object_type, object_name from user_objects where status = 'INVALID'" -c "value > 0"

  -- same as above but check for all connections in a file, use 5 worker threads
  check-oracle-query.rb -f connections.csv -t -s -query "select object_type, object_name from user_objects where status = 'INVALID'" -c "value > 0" -W 5

  ```

## Installation

[Installation and Setup](https://docs.sensu.io/sensu-core/latest/installation/installing-plugins/)

## Supported Ruby Versions

Currently supported and tested ruby versions are:

- 3.4 (EOL March 31 2028)
- 3.3 (EOL March 31 2027)
- 3.2 (EOL March 31 2026)

Ruby versions not tested anymore:

- 3.1 (EOL March 31 2025)
- 3.0 (EOL March 31 2024)
- 2.7 (EOL March 31 2023)
- 2.6 (EOL March 31 2022)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/thomis/sensu-plugins-oracle. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://www.contributor-covenant.org/) code of conduct.

1. Fork it ( https://github.com/thomis/sensu-plugins-oracle/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
