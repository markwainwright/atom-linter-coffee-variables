{allowUnsafeNewFunction} = require 'loophole'
atomPackageDeps          = require 'atom-package-deps'
coffee                   = require 'coffee-script'
eslint                   = allowUnsafeNewFunction -> require('eslint').linter
SourceMapConsumer        = require('source-map').SourceMapConsumer

_lint = (TextEditor) ->
  coffeeSource = TextEditor.getText()
  compiledData = _compileToJS coffeeSource
  _getErrors compiledData
    .map _addCodePosition compiledData
    .filter (e) -> e
    .map _errorToLinterObj TextEditor


_compileToJS = (coffeeSource) ->
  try
    results = coffee.compile coffeeSource, sourceMap: true
    js        : results.js
    sourceMap : new SourceMapConsumer JSON.parse results.v3SourceMap
    tokens    : coffee.tokens coffeeSource
  catch
    null


_getErrors = (compiledData) ->
  return [] unless compiledData?.js

  try
    allowUnsafeNewFunction ->
      eslint.verify compiledData.js,
        env: do ->
          envsArray = global.atom.config.get 'linter-coffee-variables.environments'
          envsObj   = {}
          envsObj[env] = true for env in envsArray
          envsObj
        rules:
          'no-undef'       : 2
          'no-unused-vars' : 2

  catch
    return []


_addCodePosition = (compiledData) -> (error) ->
  # Query the source map for the original position
  originalPos = compiledData.sourceMap.originalPositionFor
    line   : error.line
    column : error.column

  returnValue =
    message  : error.message
    line     : originalPos.line
    column   : originalPos.column

  # Coffee sourcemaps don't indicate where variables were originally defined, so we'll use
  # Coffeescript's generated tokens to work that out. Or we'll do the same if the
  # sourcemap didn't give us a line number for some reason
  if error.ruleId is 'no-unused-vars' or not originalPos.line
    tokenNames = error.message.match(/\".*\"/)?[0]?.replace(/\"/g, '')

    # try/catch blocks always generate an unused `error1` etc variable, so we'll ignore
    # those
    return null if /^error[0-9]$/.test tokenNames

    token = compiledData.tokens?.filter(
      (t) -> t.variable and t[1] is tokenNames
    )[0]?[2]

    if token
      returnValue.line   = token.first_line + 1
      returnValue.column = token.first_column

  returnValue


_errorToLinterObj = (TextEditor) -> (error) ->
  if typeof error.line isnt 'number' then error.line = 1
  if typeof error.column isnt 'number' then error.column = 0

  endOfLine = TextEditor.getBuffer().lineLengthForRow? error.line - 1

  type: 'Warning'
  text: error.message
  range: [
    [error.line - 1, error.column]
    [error.line - 1, endOfLine]
  ]
  filePath: TextEditor.getPath()


module.exports =
  config:
    environments:
      type        : 'array'
      default     : ['browser', 'node', 'es6']
      description : 'Environments are sets of predefined global variables that are
        allowed to be used without being defined.
        See http://eslint.org/docs/user-guide/configuring#specifying-environments for the
        full list.'

  activate: ->
    atomPackageDeps.install 'linter-coffee-variables'

  provideLinter: ->
    name          : 'CoffeeVariables'
    scope         : 'file'
    lintOnFly     : true
    lint          : _lint
    grammarScopes : [
      'source.coffee'
      'source.litcoffee'
    ]
