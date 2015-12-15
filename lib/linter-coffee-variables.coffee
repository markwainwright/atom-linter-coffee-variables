packageName = 'linter-coffee-variables'

debug = require './debug'

cache = {}


_compileToJS = (coffeeSource) ->
  SourceMapConsumer = require('source-map').SourceMapConsumer
  coffee            = require 'coffee-script'

  try
    results   = coffee.compile coffeeSource, sourceMap: true
    variables = coffee.tokens coffeeSource
      .filter (v) -> v.variable is true
      .map (v) ->
        name   : v[1]
        column : v[2].first_column
        line   : v[2].first_line + 1

    js        : results.js
    sourceMap : new SourceMapConsumer JSON.parse results.v3SourceMap
    variables : variables
  catch error
    debug.warn 'Failed to compile:', error
    {}


_getEnvs = ->
  envs = global.atom.config.get(packageName)?.environments or []
  envs.reduce (obj, env) ->
    obj[env] = true
    obj
  , {}


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


_addOriginalCodePosition = (sourceMap, variables) -> (error) ->
  variableName = error.message.match(/\".*\"/)?[0]?.replace(/\"/g, '')

  # try/catch blocks always seem to generate an unused `error1` etc variable, so we'll
  # ignore those
  # TODO: Attempt to verify that these aren't variables from the user's own code
  return if /^error[0-9]$/.test variableName

  # Query the source map for the original position
  positionFromSourcemap = sourceMap.originalPositionFor error

  # CoffeeScript sourcemaps say that all top-level variables were originally defined on
  # the same line as the first one was, so if that is the case, we'll resort to using
  # CoffeeScript's generated tokens to find out where the variable was first defined.
  firstVariableLine = (variables.map (v) -> v.line).sort((a, b) -> a-b)[0]
  if (error.ruleId is 'no-unused-vars' and positionFromSourcemap.line <= firstVariableLine) or
    not positionFromSourcemap.line
      positionFromVariableLookup = _lookUpVariablePosition(variableName, variables)[0]

  message      : error.message
  variableName : variableName
  line         : positionFromVariableLookup?.line   or positionFromSourcemap.line   or 1
  column       : positionFromVariableLookup?.column or positionFromSourcemap.column or 0


_lookUpVariablePosition = (variableName, variables) ->
  variables
    .filter (v) ->
      v.name is variableName
    .map (v) ->
      line   : v.line
      column : v.column


_errorToLinterObj = (filePath) -> (error) ->
  line   = if typeof error.line   is 'number' then error.line   else error.line   = 1
  column = if typeof error.column is 'number' then error.column else error.column = 0

  type     : 'Warning'
  text     : error.message
  filePath : filePath
  range    : [
    [line - 1, column]
    [line - 1, column + error.variableName?.length or 100]
  ]


lint = (TextEditor) ->
  debug.time 'Compiling to JS'
  {js, sourceMap, variables} = _compileToJS TextEditor.getText()
  debug.timeEnd 'Compiling to JS'

  # If the compiled JS hasn't changed since the last time, use the cached errors instead
  # of running ESLint again
  if js is cache.js
    return cache.errors

  else if js
    debug.time 'Running ESLint'
    errors = _getESLintErrors js
      .map _addOriginalCodePosition sourceMap, variables
      .filter Boolean
      .map _errorToLinterObj TextEditor.getPath()
    cache = js: js, errors: errors
    debug.timeEnd 'Running ESLint'
    return errors

  else
    return []


module.exports = {
  lint
  _getEnvs
  _compileToJS
}
