myenv-builder
=============

generate and deploy your configuration files like dot files, firefox user.js, etc.

I'm using it on FreeBSD, Linux, Windows and macOS

Requisites
----------

* Ruby
* Rake

Installation
------------

add

```ruby:Gemfile
gem "myenv-builder", github: "wtnabe/myenv-builder"
```

into Gemfile, and run `bundle install` or,

```
$ bundle add myenv-builder --github wtnabe/myenv-builder
```

Getting Started
---------------

basic layout

```
./
|-- Gemfile
|-- Rakefile
|-- dotfiles/   your dot files
|-- firefox/    your profile settings
`-- lib/        Rakefile's libraries
```

write Rakefile as

```ruby
require "myenv-builder"

MyenvBuilder::Tasks.new(base_dir: __dir__)
```

```sh
$ cd `<config dir>`
$ mv ~/.zshrc dotfiles/zshrc
$ rake dotfiles:link_priv
$ ls -l ~/
```

 .zshrc -> dotfiles/zshrc

WHAT YOU CAN
------------

1. versioning your config files
2. reuse the same config files in multiple environments
3. switch to set up config files for job or private with erb

ERB EXAMPLE
-----------

```erb
[user]
<%- if workspace == 'job' -%>
    name  = wtnabe
    email = wtnabe@example.co.jp
<%- else -%>
    name  = wtnabe
    email = 18510+wtnabe@users.noreply.github.com
<%- end -%>
[alias]
    stat = status
    ci   = commit -a
    br   = branch
    co   = checkout
    up   = update
[color]
    status = auto
    diff   = auto
[core]
    excludesfile = <%= ENV['HOME'] %>/.gitignore
```
