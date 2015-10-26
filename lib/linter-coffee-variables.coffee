debug = require './debug'

config = global.atom.config.get 'linter-coffee-variables'
cache = {}


_compileToJS = (coffeeSource) ->
  SourceMapConsumer = require('source-map').SourceMapConsumer
  coffee            = require 'coffee-script'

  try
    results = coffee.compile coffeeSource, sourceMap: true
    js        : results.js
    sourceMap : new SourceMapConsumer JSON.parse results.v3SourceMap
    tokens    : coffee.tokens coffeeSource
  catch error
    debug.warn 'Failed to compile:', error
    {}


_getEnvs = ->
  envsArray = config.environments
  envsObj   = {}
  envsObj[env] = true for env in envsArray
  envsObj


_getESLintErrors = (js) ->
  return [] unless js

  {allowUnsafeNewFunction} = require 'loophole'
  eslint = allowUnsafeNewFunction -> require('eslint').linter

  try
    allowUnsafeNewFunction ->
      eslint.verify js,
        env: _getEnvs()
        rules:
          'no-undef'       : 2
          'no-unused-vars' : 2
  catch error
    debug.warn 'ESLint failed:', error
    return []


_addOriginalCodePosition = (sourceMap, tokens) -> (error) ->
  # try/catch blocks always generate an unused `error1` etc variable, so we'll ignore
  # those
  tokenName = error.message.match(/\".*\"/)?[0]?.replace(/\"/g, '')
  return if /^error[0-9]$/.test tokenName

  # Query the source map for the original position
  originalPos = sourceMap.originalPositionFor
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
    posFromToken = _getCodePositionByToken error, tokenName, tokens
    if posFromToken
      returnValue.line   = posFromToken.line
      returnValue.column = posFromToken.column

  returnValue


_getCodePositionByToken = (error, tokenName, tokens) ->
  token = tokens?.filter(
    (t) -> t.variable and t[1] is tokenName
  )[0]?[2]

  if token
    line   : token.first_line + 1
    column : token.first_column


_errorToLinterObj = (TextEditor) -> (error) ->
  line   = if typeof error.line   is 'number' then error.line   else error.line   = 1
  column = if typeof error.column is 'number' then error.column else error.column = 0

  endOfLine = TextEditor.getBuffer().lineLengthForRow? error.line - 1

  type: 'Warning'
  text: error.message
  range: [
    [line - 1, column]
    [line - 1, endOfLine]
  ]
  filePath: TextEditor.getPath()


_lint = (TextEditor) ->
  debug.time 'Compiling to JS'
  {js, sourceMap, tokens} = _compileToJS TextEditor.getText()
  debug.timeEnd 'Compiling to JS'

  # If the compiled JS hasn't changed since the last time, use the cached errors instead
  # of running ESLint again
  if js is cache.js
    return cache.errors

  else if js
    debug.time 'Running ESLint'
    errors = _getESLintErrors js
      .map _addOriginalCodePosition sourceMap, tokens
      .filter Boolean
      .map _errorToLinterObj TextEditor
    cache = js: js, errors: errors
    debug.timeEnd 'Running ESLint'
    return errors

  else
    return []


module.exports =
  lint: _lint
