packageName = require('../package').name

inDebugMode = ->
  global.atom.config.get(packageName).debug


consoleWrapper = (method) ->
  (messages...) ->
    # If debug is enabled in package config, call through to the console[method] function,
    # supporting variadic arguments
    if inDebugMode()
      args = ["[#{ packageName }]"].concat messages
      Function.prototype.apply.call console[method], console, args


module.exports =
  log  : consoleWrapper 'log'
  info : consoleWrapper 'info'
  warn : consoleWrapper 'warn'

  time: (message) ->
    if inDebugMode() then console.time "[#{ packageName }] #{ message }"

  timeEnd: (message) ->
    if inDebugMode() then console.timeEnd "[#{ packageName }] #{ message }"

  table: (message, obj) ->
    if inDebugMode()
      console.log "[#{ packageName }] #{ message }"
      console.table obj

  logCache: (cache) ->
    if inDebugMode()
      if cache.keys?.length
        table = {}
        table[path] = cache.get(path) for path in cache.keys
        console.table table
      else
        console.log null
