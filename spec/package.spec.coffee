fs                    = require 'fs'
path                  = require 'path'

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

    expectedErrors =
      [
        {
          "type": "Warning",
          "text": "\"b\" is defined but never used",
          "filePath": "/Users/mark/web/linter-coffee-variables/spec",
          "range": [
            [
              2,
              0
            ],
            [
              2,
              1
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"c\" is not defined.",
          "filePath": "/Users/mark/web/linter-coffee-variables/spec",
          "range": [
            [
              4,
              1
            ],
            [
              4,
              2
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"d\" is not defined.",
          "filePath": "/Users/mark/web/linter-coffee-variables/spec",
          "range": [
            [
              5,
              2
            ],
            [
              5,
              3
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"e\" is not defined.",
          "filePath": "/Users/mark/web/linter-coffee-variables/spec",
          "range": [
            [
              8,
              2
            ],
            [
              8,
              3
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"f1a3\" is defined but never used",
          "filePath": "/Users/mark/web/linter-coffee-variables/spec",
          "range": [
            [
              10,
              18
            ],
            [
              10,
              22
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"f1a4\" is not defined.",
          "filePath": "/Users/mark/web/linter-coffee-variables/spec",
          "range": [
            [
              12,
              2
            ],
            [
              12,
              6
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"f2a3\" is not defined.",
          "filePath": "/Users/mark/web/linter-coffee-variables/spec",
          "range": [
            [
              16,
              2
            ],
            [
              16,
              6
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"f2a4\" is not defined.",
          "filePath": "/Users/mark/web/linter-coffee-variables/spec",
          "range": [
            [
              17,
              2
            ],
            [
              17,
              6
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"f4a1\" is defined but never used",
          "filePath": "/Users/mark/web/linter-coffee-variables/spec",
          "range": [
            [
              22,
              6
            ],
            [
              22,
              10
            ]
          ]
        },
        {
          "type": "Warning",
          "text": "\"f4\" is not defined.",
          "filePath": "/Users/mark/web/linter-coffee-variables/spec",
          "range": [
            [
              28,
              0
            ],
            [
              28,
              2
            ]
          ]
        }
      ]

    # console.log JSON.stringify errors, null, 2
    expect(JSON.stringify errors).toEqual(JSON.stringify expectedErrors)


describe '_getEnvs', ->
  it 'correctly transforms config array to ESLint object', ->
    expect(linterCoffeeVariables._getEnvs()).toEqual
      browser : true
      node    : true
      es6     : true


describe '_compileToJS', ->
  it 'returns compiled data in correct shape', ->
    {js, sourceMap, variables} = linterCoffeeVariables._compileToJS fixture

    expect(js).toEqual jasmine.any String
    expect(js).toContain '(function() {'
    expect(js).toContain '}).call(this);'

    expect(sourceMap).toEqual jasmine.any Object
    expect(variables).toEqual jasmine.any Array
