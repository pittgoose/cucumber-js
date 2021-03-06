Feature: After hook interface

  Background:
    Given a file named "features/my_feature.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given a step
      """
    And a file named "features/step_definitions/my_steps.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({When}) => {
        When(/^a step$/, function() {
          this.value = 1;
        })
      })
      """

  Scenario Outline: too many arguments
    Given a file named "features/support/hooks.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({<TYPE>}) => {
        <TYPE>(function(arg1, arg2, arg3) {})
      })
      """
    When I run cucumber.js
    Then it fails
    And the output contains the text:
      """
      function has 3 arguments, should have 0 or 1 (if synchronous or returning a promise) or 2 (if accepting a callback)
      """

    Examples:
      | TYPE   |
      | Before |
      | After  |

  Scenario Outline: synchronous
    Given a file named "features/support/hooks.js" with:
      """
      import {defineSupportCode} from 'cucumber'
      import assert from 'assert'

      defineSupportCode(({<TYPE>}) => {
        <TYPE>(function() {})
      })
      """
    When I run cucumber.js
    Then it passes

    Examples:
      | TYPE   |
      | Before |
      | After  |

  Scenario Outline: synchronously throws
    Given a file named "features/support/hooks.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({<TYPE>}) => {
        <TYPE>(function() {
          throw new Error('my error')
        })
      }
      """
    When I run cucumber.js
    Then it fails

    Examples:
      | TYPE   |
      | Before |
      | After  |

  Scenario Outline: callback without error
    Given a file named "features/support/hooks.js" with:
      """
      import {defineSupportCode} from 'cucumber'
      import assert from 'assert'

      defineSupportCode(({<TYPE>}) => {
        <TYPE>(function(scenario, callback) {
          setTimeout(callback)
        })
      })
      """
    When I run cucumber.js
    Then it passes

    Examples:
      | TYPE   |
      | Before |
      | After  |

  Scenario Outline: callback with error
    Given a file named "features/support/hooks.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({<TYPE>}) => {
        <TYPE>(function(scenario, callback) {
          setTimeout(() => {
            callback(new Error('my error'))
          })
        })
      })
      """
    When I run cucumber.js
    Then it fails

    Examples:
      | TYPE   |
      | Before |
      | After  |

  Scenario Outline: callback asynchronously throws
    Given a file named "features/support/hooks.js" with:
      """
      import {defineSupportCode} from 'cucumber'

      defineSupportCode(({<TYPE>}) => {
        <TYPE>(function(scenario, callback) {
          setTimeout(() => {
            throw new Error('my error')
          })
        })
      })
      """
    When I run cucumber.js
    Then it fails

    Examples:
      | TYPE   |
      | Before |
      | After  |

  Scenario Outline: callback - returning a promise
    Given a file named "features/step_definitions/failing_steps.js" with:
      """
      import {defineSupportCode} from 'cucumber'
      import Promise from 'bluebird'

      defineSupportCode(({<TYPE>}) => {
        <TYPE>(function(scenario, callback) {
          return Promise.resolve()
        })
      })
      """
    When I run cucumber.js
    Then it fails
    And the output contains the text:
      """
      function uses multiple asynchronous interfaces: callback and promise
      """

    Examples:
      | TYPE   |
      | Before |
      | After  |

  Scenario Outline: promise resolves
    Given a file named "features/support/hooks.js" with:
      """
      import {defineSupportCode} from 'cucumber'
      import Promise from 'bluebird'

      defineSupportCode(({<TYPE>}) => {
        <TYPE>(function() {
          return Promise.resolve()
        })
      })
      """
    When I run cucumber.js
    Then it passes

    Examples:
      | TYPE   |
      | Before |
      | After  |

  Scenario Outline: promise rejects with error
    Given a file named "features/support/hooks.js" with:
      """
      import {defineSupportCode} from 'cucumber'
      import Promise from 'bluebird'

      defineSupportCode(({<TYPE>}) => {
        <TYPE>(function(){
          return Promise.reject(new Error('my error'))
        })
      })
      """
    When I run cucumber.js
    Then it fails
    And the output contains the text:
      """
      my error
      """

    Examples:
      | TYPE   |
      | Before |
      | After  |

  Scenario Outline: promise rejects without error
    Given a file named "features/support/hooks.js" with:
      """
      import {defineSupportCode} from 'cucumber'
      import Promise from 'bluebird'

      defineSupportCode(({<TYPE>}) => {
        <TYPE>(function() {
          return Promise.reject()
        })
      })
      """
    When I run cucumber.js
    Then it fails
    And the output contains the text:
      """
      Promise rejected without a reason
      """

    Examples:
      | TYPE   |
      | Before |
      | After  |

  Scenario Outline: promise asynchronously throws
    Given a file named "features/support/hooks.js" with:
      """
      import {defineSupportCode} from 'cucumber'
      import Promise from 'bluebird'

      defineSupportCode(({<TYPE>}) => {
        <TYPE>(function(){
          return new Promise(function() {
            setTimeout(() => {
              throw new Error('my error')
            })
          })
        })
      })
      """
    When I run cucumber.js
    Then it fails
    And the output contains the text:
      """
      my error
      """

    Examples:
      | TYPE   |
      | Before |
      | After  |

  Scenario Outline: hook step match location with support code aliases
    Given a file named "features/support/hooks.js" with:
      """
      let {<TYPE>} = require('cucumber')

      <TYPE>(function(arg1, arg2) {
      })
      """
    When I run cucumber.js
    Then it fails
    And the output contains the text:
      """
      Step Definition: features\support\hooks.js:3
      """
    Examples:
      | TYPE   |
      | Before |
      | After  |
