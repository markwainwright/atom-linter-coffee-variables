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
          'type': 'Warning',
          'text': '\"bb\" is defined but never used',
          'filePath': __dirname,
          'range': [
            [
              4,
              0
            ],
            [
              4,
              2
            ]
          ]
        },
        {
          'type': 'Warning',
          'text': '\"ccc\" is defined but never used',
          'filePath': __dirname,
          'range': [
            [
              5,
              0
            ],
            [
              5,
              3
            ]
          ]
        },
        {
          'type': 'Warning',
          'text': '\"dddd\" is defined but never used',
          'filePath': __dirname,
          'range': [
            [
              6,
              0
            ],
            [
              6,
              4
            ]
          ]
        },
        {
          'type': 'Warning',
          'text': '\"func1\" is defined but never used',
          'filePath': __dirname,
          'range': [
            [
              14,
              0
            ],
            [
              14,
              5
            ]
          ]
        },
        {
          'type': 'Warning',
          'text': '\"eeeee\" is not defined.',
          'filePath': __dirname,
          'range': [
            [
              8,
              0
            ],
            [
              8,
              5
            ]
          ]
        },
        {
          'type': 'Warning',
          'text': '\"ggggggg\" is not defined.',
          'filePath': __dirname,
          'range': [
            [
              9,
              0
            ],
            [
              9,
              7
            ]
          ]
        },
        {
          'type': 'Warning',
          'text': '\"hhhhhhhh\" is not defined.',
          'filePath': __dirname,
          'range': [
            [
              12,
              2
            ],
            [
              12,
              10
            ]
          ]
        },
        {
          'type': 'Warning',
          'text': '\"arg3\" is defined but never used',
          'filePath': __dirname,
          'range': [
            [
              14,
              21
            ],
            [
              14,
              25
            ]
          ]
        },
        {
          'type': 'Warning',
          'text': '\"arg4\" is not defined.',
          'filePath': __dirname,
          'range': [
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
          'type': 'Warning',
          'text': '\"arg3\" is not defined.',
          'filePath': __dirname,
          'range': [
            [
              20,
              2
            ],
            [
              20,
              6
            ]
          ]
        },
        {
          'type': 'Warning',
          'text': '\"arg4\" is not defined.',
          'filePath': __dirname,
          'range': [
            [
              21,
              2
            ],
            [
              21,
              6
            ]
          ]
        },
        {
          'type': 'Warning',
          'text': '\"func3\" is not defined.',
          'filePath': __dirname,
          'range': [
            [
              24,
              0
            ],
            [
              24,
              5
            ]
          ]
        },
        {
          'type': 'Warning',
          'text': '\"usedInF1ButNotF2\" is defined but never used',
          'filePath': __dirname,
          'range': [
            [
              26,
              6
            ],
            [
              26,
              22
            ]
          ]
        }
      ]

    expect(JSON.stringify errors).toEqual(JSON.stringify expectedErrors)


describe '_getEnvs', ->
  it 'correctly transforms config array to ESLint object', ->
    expect(do linterCoffeeVariables._getEnvs ).toEqual
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
