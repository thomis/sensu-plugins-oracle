
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-oracle.svg)](https://badge.fury.io/rb/sensu-plugins-oracle)
[![Code Climate](https://codeclimate.com/github/thomis/sensu-plugins-oracle/badges/gpa.svg)](https://codeclimate.com/github/thomis/sensu-plugins-oracle)
[![Dependency Status](https://gemnasium.com/badges/github.com/thomis/sensu-plugins-oracle.svg)](https://gemnasium.com/github.com/thomis/sensu-plugins-oracle)

# sensu-plugins-oracle

This sensu plugin provides native Oracle instrumentation.

## Files
 * bin/check-oracle-alive.rb

## Usage

  ```
  check-oracle-alive.rb -u scott -p tiger -d hr

  check-oracle-alive.rb -u scott -p tiger -d ht -T 30
  ```

  ```
  check-oracle-alive.rb -f connections.csv

  > cat connections.csv
  # production connection
  example_connection_1,scott/tiger@hr

  # test connection
  example_connection_2,scott/tiger@hr_test

  ```

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)
