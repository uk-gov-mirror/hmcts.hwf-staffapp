# Fee Remissions - Staff App
[![Code Climate](https://codeclimate.com/github/ministryofjustice/fr-staffapp/badges/gpa.svg)](https://codeclimate.com/github/ministryofjustice/fr-staffapp) [![Test Coverage](https://codeclimate.com/github/ministryofjustice/fr-staffapp/badges/coverage.svg)](https://codeclimate.com/github/ministryofjustice/fr-staffapp/coverage?sort=covered_percent&sort_direction=asc) [![Build Status](https://travis-ci.org/ministryofjustice/fr-staffapp.svg?branch=master)](https://travis-ci.org/ministryofjustice/fr-staffapp) [![Dependency Status](https://gemnasium.com/badges/github.com/ministryofjustice/fr-staffapp.svg)](https://gemnasium.com/github.com/ministryofjustice/fr-staffapp)

## Overview

This app is used by staff in the courts and tribunals to enter data regarding fee remission applications,
record the decision, and collect statistics.

## Project Standards

- Authentications via Devise / CanCanCan
- Rspec features, not cucumber
- Slim templating language
- Foundation view framework
- JavaScript in preference to Coffeescript

## Pre-requisites
To run the headless tests you will need to install quicktime for capybara-webkit:
```
brew install qt
```
You will need to run the following to enable capybara-webkit in ubuntu environments:
```
sudo apt-get install qt5-default libqt5webkit5-dev
sudo apt-get install xvfb
```

## Cucumber Test Suite
By default, the cucumber test suite will boot up a server to communicate with and the tests will
run against that using the 'rest-client' gem.
However, if you are developing, this can be a little inconvenient as errors will just come back as something like 'Internal server error' which is not
very helpful.

But, you can use rack_test instead which will mean no server is involved and the test suite
talks to the API using the internal rack interface, which is all in the same process meaning useful
error messages and backtraces for debugging.

Remember, that rack_test is a fake environment though and it is very important that we test in the same way
that a user would access our API - meaning through HTTP.

Also remember that running with a real server in an external process (i.e. without rack_test) means no
stubbing etc.. as your test code is running in a separate server.  Exceptions are libraries like
webmock that are designed for this and will start up before the server thread is started.
This restriction of no mocking enforces tests to be written so that they use the API as a normal API user would.  A normal API user cannot modify our application code, so our tests shouldn't.

To enable rack_test mode, set the 'USE_RACK_TEST' environment variable to 'true' before running
the test suite.

If you need to run the test suite against an external API - set the CALCULATOR_URL environment variable to
point to http://<yourserver>:<yourport>/calculator

#### Creating initial user
There is a rake task that takes email, password and role

```
rake user:create
```

If you want to add any custom options, use the below as an example:

```
rake "user:create[user@hmcts.gsi.gov.uk, 123456789, admin, name]"
```
__Note:__ the quotes around the task are important!
