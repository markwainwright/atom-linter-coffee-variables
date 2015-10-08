# linter-coffee-variables

This is a plugin for [Linter](https://github.com/atom-community/linter) that does some
things that [CoffeeLint](https://github.com/AtomLinter/linter-coffeelint) can't: detecting
variables that are used before they are defined, and defined variables that aren't used.

It's best used in conjunction with
[linter-coffeelint](https://github.com/AtomLinter/linter-coffeelint).

Behind the scenes it achieves this by compiling your CoffeeScript to JavaScript and
running it through [ESLint](http://eslint.org), using specific rules.

Installation

1. [Install Linter](https://github.com/atom-community/linter#user-content-how-to--installation)
2. `$ apm install linter-coffeelint`
