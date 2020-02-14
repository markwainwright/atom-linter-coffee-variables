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

textEditorStub =
  getText: -> fixture
  getPath: -> __dirname
  getGrammar: -> { scopeName: 'source.coffee' }
  getTitle: -> ''


describe 'Linting a CoffeeScript fixture', ->
  it 'returns expected errors', ->
    errors = linterCoffeeVariables.lint textEditorStub

    expectedErrors =
      [
        {
          "severity": "warning",
          "excerpt": "\"b\" is defined but never used",
          "location": {
            "file": __dirname,
            "position": [
              [
                4,
                0
              ],
              [
                4,
                1
              ]
            ]
          }
        },
        {
          "severity": "warning",
          "excerpt": "\"c\" is not defined.",
          "location": {
            "file": __dirname,
            "position": [
              [
                6,
                1
              ],
              [
                6,
                2
              ]
            ]
          }
        },
        {
          "severity": "warning",
          "excerpt": "\"d\" is not defined.",
          "location": {
            "file": __dirname,
            "position": [
              [
                7,
                2
              ],
              [
                7,
                3
              ]
            ]
          }
        },
        {
          "severity": "warning",
          "excerpt": "\"e\" is not defined.",
          "location": {
            "file": __dirname,
            "position": [
              [
                10,
                2
              ],
              [
                10,
                3
              ]
            ]
          }
        },
        {
          "severity": "warning",
          "excerpt": "\"f1a3\" is defined but never used",
          "location": {
            "file": __dirname,
            "position": [
              [
                12,
                18
              ],
              [
                12,
                22
              ]
            ]
          }
        },
        {
          "severity": "warning",
          "excerpt": "\"f1a4\" is not defined.",
          "location": {
            "file": __dirname,
            "position": [
              [
                14,
                2
              ],
              [
                14,
                6
              ]
            ]
          }
        },
        {
          "severity": "warning",
          "excerpt": "\"f2a3\" is not defined.",
          "location": {
            "file": __dirname,
            "position": [
              [
                18,
                2
              ],
              [
                18,
                6
              ]
            ]
          }
        },
        {
          "severity": "warning",
          "excerpt": "\"f2a4\" is not defined.",
          "location": {
            "file": __dirname,
            "position": [
              [
                19,
                2
              ],
              [
                19,
                6
              ]
            ]
          }
        },
        {
          "severity": "warning",
          "excerpt": "\"f4a1\" is defined but never used",
          "location": {
            "file": __dirname,
            "position": [
              [
                24,
                6
              ],
              [
                24,
                10
              ]
            ]
          }
        },
        {
          "severity": "warning",
          "excerpt": "\"f4\" is not defined.",
          "location": {
            "file": __dirname,
            "position": [
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


{js, rawSourceMap} = linterCoffeeVariables._compileToJS fixture, textEditorStub

describe '_compileToJS', ->

  it 'returns compiled data in correct shape', ->
    expect(js).to.be.a 'string'
    expect(js).to.contain '(function() {'
    expect(js).to.contain '}).call(this);'

    expect(rawSourceMap).to.be.a 'string'
    # expect(variables).to.be.an 'array'


describe '_parseSourceMap', ->

  it 'returns parsed sourcemap object', ->
    sourcemap = linterCoffeeVariables._parseSourceMap rawSourceMap
    expect(sourcemap).to.be.an 'object'
    expect(sourcemap.originalPositionFor).to.be.a 'function'

  it 'returns null if sourcemap cannot be parsed', ->
    sourcemap = linterCoffeeVariables._parseSourceMap null
    expect(sourcemap).to.be.null

    sourcemap = linterCoffeeVariables._parseSourceMap 'foobar'
    expect(sourcemap).to.be.null

    sourcemap = linterCoffeeVariables._parseSourceMap [1, 2]
    expect(sourcemap).to.be.null
