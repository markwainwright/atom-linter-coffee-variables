fs     = require 'fs'
path   = require 'path'
expect = require('chai').expect

linterCoffeeVariables = require '../lib/linter-coffee-variables'

fixture = fs.readFileSync (path.join __dirname, 'fixture.coffee'), 'utf8'

# Stub config
global.atom =
  config:
    get: ->
      environments : ['browser', 'node', 'es6']
      debug        : false

# Stub TextEditor
textEditorStub =
  getText: -> fixture
  getPath: -> __dirname


describe 'Linting a CoffeeScript fixture', ->
  it 'returns expected errors', ->
    errors = linterCoffeeVariables.lint textEditorStub
    filepath = errors[0].filePath
    expect(filepath).to.include('linter-coffee-variables/spec')

    expectedErrors =
      [
        {
          "type": "Warning",
          "text": "\"b\" is defined but never used",
          "filePath": filepath,
          "range": [
            [
              4,
              0
            ],
            [
              4,
              1
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"c\" is not defined.",
          "filePath": filepath,
          "range": [
            [
              6,
              1
            ],
            [
              6,
              2
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"d\" is not defined.",
          "filePath": filepath,
          "range": [
            [
              7,
              2
            ],
            [
              7,
              3
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"e\" is not defined.",
          "filePath": filepath,
          "range": [
            [
              10,
              2
            ],
            [
              10,
              3
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"f1a3\" is defined but never used",
          "filePath": filepath,
          "range": [
            [
              12,
              18
            ],
            [
              12,
              22
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"f1a4\" is not defined.",
          "filePath": filepath,
          "range": [
            [
              14,
              2
            ],
            [
              14,
              6
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"f2a3\" is not defined.",
          "filePath": filepath,
          "range": [
            [
              18,
              2
            ],
            [
              18,
              6
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"f2a4\" is not defined.",
          "filePath": filepath,
          "range": [
            [
              19,
              2
            ],
            [
              19,
              6
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"f4a1\" is defined but never used",
          "filePath": filepath,
          "range": [
            [
              24,
              6
            ],
            [
              24,
              10
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"f4\" is not defined.",
          "filePath": filepath,
          "range": [
            [
              30,
              0
            ],
            [
              30,
              2
            ]
          ]
        }
      ]

    # console.log JSON.stringify errors, null, 2
    expect(errors).to.deep.equal expectedErrors


describe '_getEnvs', ->
  it 'correctly transforms config array to ESLint object', ->
    expect(linterCoffeeVariables._getEnvs()).to.deep.equal
      browser : true
      node    : true
      es6     : true


describe '_compileToJS', ->
  it 'returns compiled data in correct shape', ->
    {js, sourceMap, variables} = linterCoffeeVariables._compileToJS fixture

    expect(js).to.be.a 'string'
    expect(js).to.contain '(function() {'
    expect(js).to.contain '}).call(this);'

    expect(sourceMap).to.be.an 'object'
    expect(variables).to.be.an 'array'
