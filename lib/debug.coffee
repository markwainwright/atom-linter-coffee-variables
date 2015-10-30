packageName = 'linter-coffee-variables'

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
