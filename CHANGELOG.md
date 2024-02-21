## 0.14.0 - 2024-02-21

Changed:
- Update Dependencies

## 0.13.0 - 2023-12-25

Changed:
- Adapt CI/CD to use ruby 3.3.0

## 0.12.0 - 2022-08-19

Changed:
- Adapt CI/CD to actual ruby versions
- Update Dependencies

## 0.11.0 - 2022-07-27

Added:
- Use of Depandabot
- Use of GitHub actions
- Use of Ruby style guide and linter
- Use of Code Climate test coverage

## 0.10.0 - 2019-05-12

Added:
- Option to define module that the oracle sessions will use (thanks to [@zalum](https://github.com/zalum))

Bug Fixes:
- Fix use of wrong version constant (thanks to [@aurelije](https://github.com/aurelije))

## 0.9.1 - 2018-11-25

Major:
- Optional limitation of output text size (alive and query)
- Update to sensu-plugin 2.7
- Update all gem dependencies

## 0.8.0 - 2018-06-20

Major:
- Update to sensu-plugin 2.5
- Update gem dependencies: dentaku, rake

## 0.6.0 - 2017-08-28

Major:
- Update to sensu-plugin 2.3

Bug Fixes:
- Fix colliding -w short option. Worker count short option is now -W (Thanks to [@aurelije](https://github.com/aurelije))

## 0.5.0 - 2017-07-27

Major:
- Parallel processing with threads and queues, allow to define number of threads
- Refactored code to remove doublication
- Verbose output for thread processing

## 0.4.2 - 2017-07-24

Bug Fixes:
- Fix permissions of all files

## 0.4.1 - 2017-07-24

Bug Fixes:
- read permission of command files

## 0.4.0 - 2017-07-24

Major:
- Update sensu gem
- Apply timeout argument to all uderlying oracle timeout properties (tcp_connect_timeout, connect_timeout, send_timeout, recv_timeout)

Minor:
- Update dekantu gem
- Update development dependencies


## 0.1.0 - 2016-08-04

Major:
- first version which is able to check a single or multiple oracle connections

## 0.0.1 - 2016-08-03

Major:
- initial release based on sensu-plugins-postgres (https://github.com/sensu-plugins/sensu-plugins-postgres)
