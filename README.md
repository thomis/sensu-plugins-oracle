
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-oracle.svg)](https://badge.fury.io/rb/sensu-plugins-oracle)
[![Code Climate](https://codeclimate.com/github/thomis/sensu-plugins-oracle/badges/gpa.svg)](https://codeclimate.com/github/thomis/sensu-plugins-oracle)
[![Dependency Status](https://gemnasium.com/badges/github.com/thomis/sensu-plugins-oracle.svg)](https://gemnasium.com/github.com/thomis/sensu-plugins-oracle)

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
  -- check multiple connections as defined in a file, use 5 worker threads (-w 5) and verbose output (-v)
  check-oracle-alive.rb -f connections.csv -w 5 -v

  > cat connections.csv
    # production connection
    example_connection_1,scott/tiger@hr

    # test connection
    example_connection_2,scott/tiger@hr_test
  ```

  ```
  -- check for invalid objects in a schema, show type and name if there are invalid objects (-s), define a ciritical boundary only (-c)
  check-oracle-query.rb -u scott -p tiger -d hr -t -s -query "select object_type, object_name from user_objects where status = 'INVALID'" -c 'value > 0'

  -- same as above but check for all connections in a file
  check-oracle-query.rb -f connections.csv -t -s -query "select object_type, object_name from user_objects where status = 'INVALID'" -c 'value > 0'

  ```

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)
