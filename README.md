# [linter-coffee-variables](https://atom.io/packages/linter-coffee-variables) ![](https://img.shields.io/apm/dm/linter-coffee-variables.svg)

This is a plugin for [Linter](https://github.com/atom-community/linter) that does some
things that [CoffeeLint](https://github.com/AtomLinter/linter-coffeelint) can't: detecting
variables that are used without being defined, and defined variables that aren't used.

It's best used in conjunction with
[linter-coffeelint](https://github.com/AtomLinter/linter-coffeelint).

Behind the scenes it works by compiling your CoffeeScript to JavaScript and running it
through [ESLint](http://eslint.org), using specific rules.

Installation

1. [Install Linter](https://github.com/atom-community/linter#user-content-how-to--installation)
2. `$ apm install linter-coffee-variables`
