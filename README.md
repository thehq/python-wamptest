# WAMPTEST

[![PyPi version](https://img.shields.io/pypi/v/wamptest.svg)](https://pypi.python.org/pypi/wamptest)
[![PyPi downloads](https://img.shields.io/pypi/dm/wamptest.svg)](https://pypi.python.org/pypi/wamptest)
[![Circle CI](https://img.shields.io/circleci/token/c7cf88195fd06c83918d352636111c8476fb1400/project/thehq/python-wamptest/master.svg)](https://circleci.com/gh/thehq/python-wamptest/tree/master)
[![PyPi license](https://img.shields.io/pypi/l/crossbarhttp.svg)](https://pypi.python.org/pypi/crossbarhttp)

**wamptest** is a library created for testing WAMP services that is based on "unittest".  

## Revision History

  - v0.3.3
    - Updated Uncaught Exception to print stack trace
  - v0.3.2
    - Updated all prints to print to standard error
  - v0.3.1
    - Moved final print messages to print to standard error to ensure they are always printed
  - v0.3.0
    - Added WAMPCRA auth handling
  - v0.2.11
    - Add flush of stdout so results are printed when there are errors
  - v0.2.8-0.2.10
    - Fixing issues with exceptions
  - v0.2.7
    - Added "assertRaises"
  - v0.2.6
    - Fixed issue with running tests back to back
    - Improved documentation
  - v0.2.5
    - Initial revision

## Installation

    pip install wamptest

## Usage

The Twisted library uses a method called "defers" with a reactor which is not friendly to the unittest library.  I tried
using "Trial" but it was also not suiting my needs since it needs to run a reactor.  I wanted something that allowed 
test suites to be created for connecting to an actual router.

The library creates a class called "wamptest.TestCase" that subclasses from "autobahn.twisted.wamp.ApplicationSession" 
which will allow it to connect to a router.  When you call "main" it will iterate through an array of test cases
that will do the following

  - Connect to the router using an ApplicationRunner
  - For each test case in the test cases
    - Iterate through the tests (any method that start with "test_")
    - Gather pass/fail information
    - Stop the reactor
  - Print Pass/Fail summary.
  
The test is run by calling "main".  Here is an example

    code = wamptest.main(
        test_cases=[ExampleTestCase1, ExampleTestCase2],
        url=u"ws://router:8080/ws",
        realm=u"realm1"
    )
    
For WAMPCRA authentication, simply include "user" and "secret" in the call to main

    code = wamptest.main(
        test_cases=[ExampleTestCase1, ExampleTestCase2],
        url=u"ws://router:8080/ws",
        realm=u"realm1",
        user=u"user",
        secret=u"secret"
    )
    
It supports the following "unittest" like life cycle callbacks

  - setUpClass(cls): Called once at the start of the Test Case
  - setUp(self): Called once before each test
  - tearDown(self): Called once after each test
  - tearDownClass(cls): Called once at the end of the Test Case
    
It supports the following "unittest" like asserts

  - assertEqual(a, b, msg=None)
  - assertNotEqual(a, b, msg=None)
  - assertIsNone(a, msg=None)
  - assertIsNotNone(a, msg=None)
  - assertTrue(a, msg=None)
  - assertFalse(a, msg=None)
  - assertGreater(a, b, msg=None)
  - assertGreaterEqual(a, b, msg=None)
  - assertLess(a, b, msg=None)
  - assertLessEqual(a, b, msg=None)
  - assertRaises(exc, msg=None)
  
Writing tests must use inlineCallbacks to halt the test until completion.  An example is as follows

    import wamptest

    class ExampleTestCase(wamptest.TestCase):
    
        def __init__(self, *args, **kwargs):
            super(ExampleTestCase, self).__init__(*args, **kwargs)
            self.update = None
    
        @inlineCallbacks
        def test_1(self):
            result = yield self.call("test.add", 1, 2)
            self.assertEqual(3, result)
    
        def receive_update(self, update=None):
            self.update = update
    
        @inlineCallbacks
        def test_2(self):
            self.subscribe(self.receive_update, topic="test.trigger.update")
    
            yield self.call("test.trigger")
    
            yield sleep(2)
    
            self.assertEqual("test", self.update)
            
        @inlineCallbacks
        def test_3(self):
            with self.assertRaises(Exception) as context:
                yield self.call("test.trigger.exception")

At the completion of a test, a summary will be printed to the screen that looks something like the following

    Connecting to the url: 'ws://router:8080/ws', realm: 'realm1'

    Result: PASSED
        Tests: 2
        Passes: 2
        Failures: 0
        Errors: 0

Results are defined as follows

  - UNKNOWN: No passes, no failures, no errors
  - PASSED: At least 1 pass, no failures, no errors
  - FAILED: At least 1 failure or error

## Contributing
To contribute, fork the repo and submit a pull request.  I have the following known "TODO"s.

## TODOs

  - Implement authenticated connections
  - Make library discover test cases so you don't need to pass them in
  - Exit on Exceptions (deferred library catches them on callbacks)
  - When a failure is sensed in a test, the test still continues but the remaining errors are suppressed.  Will need
    to figure out how to end the tests

## Testing
The unit tests can be run with

    %> python /tests/run_tests.py
    
This will test basic functionality.  The overall system test (which will also run the unit tests) can be run by using
Docker Compose.  Connect to a docker host and type

    %> docker-compose build
    %> docker-compose up
    
This will run the unit tests as well as the system level tests.  The service "wamptest_test_1" will return a 0 value
if the tests were successful and non zero otherwise.  To get the pass/fail results from a command line, do the following

    #!/usr/bin/env bash
    
    docker-compose build
    docker-compose up
    
    exit $(docker-compose ps -q | xargs docker inspect -f '{{ .Name }} exited with status {{ .State.ExitCode }}' | grep test_1 | cut -f5 -d ' ')

This is a little hacky (and hopefully Docker will fix it) but it will do the trick for now.

The Docker Compose file creates a generic router with an example service connected to it and then creates a test suite 
using "wamptest" to test the service.

## License
MIT
