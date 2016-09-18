packageName = require('../package').name

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
      description : 'Output debug and profiling information to console.'


  activate: ->
    debug.time 'Activating'
    atomPackageDeps.install packageName

    # When a window is closed, remove the cached errors for that file to prevent memory
    # leaks.
    global.atom.workspace.observeTextEditors (textEditor) ->
      textEditor?.onDidDestroy =>
        linterCoffeeVariables.removeTextEditorFromCache(textEditor)

    debug.timeEnd 'Activating'


  provideLinter: ->
    name          : 'CoffeeVariables'
    scope         : 'file'
    lintOnFly     : true
    lint          : linterCoffeeVariables.lint
    grammarScopes : ['source.coffee', 'source.litcoffee']
