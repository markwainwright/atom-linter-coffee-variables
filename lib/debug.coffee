packageName = 'linter-coffee-variables'
debug       = global.atom.config.get(packageName).debug

consoleHelper = (method) ->
  (messages...) ->
    if debug
      args = ["[#{ packageName }]"].concat messages
      Function.prototype.apply.call console[method], console, args

module.exports =
  log  : consoleHelper 'log'
  info : consoleHelper 'info'
  warn : consoleHelper 'warn'

  time: (message) ->
    if debug then console.time "[#{ packageName }] #{ message }"

  timeEnd: (message) ->
    if debug then console.timeEnd "[#{ packageName }] #{ message }"
