atomPackageDeps       = require 'atom-package-deps'
linterCoffeeVariables = require './linter-coffee-variables'
debug                 = require './debug'

module.exports =
  config:
    environments:
      type        : 'array'
      default     : ['browser', 'node', 'es6']
      description : 'Environments are sets of predefined global variables that are
        allowed to be used without being defined.
        See http://eslint.org/docs/user-guide/configuring#specifying-environments for the
        full list.'
    debug:
      type        : 'boolean'
      default     : false
      description : 'Output debug and timing information to console.'

  activate: ->
    debug.time 'Activating'
    atomPackageDeps.install 'linter-coffee-variables'
    debug.timeEnd 'Activating'

  provideLinter: ->
    name          : 'CoffeeVariables'
    scope         : 'file'
    lintOnFly     : true
    lint          : linterCoffeeVariables.lint
    grammarScopes : ['source.coffee', 'source.litcoffee']
