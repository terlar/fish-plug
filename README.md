# fish-plug [![Build Status](https://travis-ci.org/terlar/fish-plug.png?branch=master)](https://travis-ci.org/terlar/fish-plug)

:fish: A simple plugin manager for [fish](https://github.com/fish-shell/fish-shell).

## Installation

```fish
git clone git://github.com/terlar/fish-plug.git
cd fish-plug
make install
```

## Configuration

There is no specific configuration except paths. They are configured
through variables. By default those variables will be universal. The
paths listed below are the defaults.

```fish
# Where plug will clone repos:
$ set plug_path $HOME/.config/fish/plug

# Where plug will install functions:
$ set plug_function_path $HOME/.config/fish/functions

# Where plug will install completions:
$ set plug_complete_path $HOME/.config/fish/completions

# Where plug will install configs:
$ set plug_config_path $HOME/.config/fish/conf.d
```

## Examples

Get help:

```fish
$ plug help
...

List installed plugins:

```fish
$ plug
fry
pisces
```

Install plugin:

```fish
$ plug install terlar/fry
plug: installed 'fry'
$ plug install https://github.com/terlar/fry.git
plug: installed 'fry'
$ plug install git@github.com:terlar/fry.git
plug: installed 'fry'
```

Update plugins:

```fish
$ plug update
Current branch master is up to date.
plug: updated 'fry'
Current branch master is up to date.
plug: updated 'pisces'
$ plug update fry
Current branch master is up to date.
plug: updated 'fry'
```

Remove plugin:

```fish
$ plug rm fry
plug: removed 'fry'
```
