---
layout: post
title: Ruby (and Jekyll) on Mac
subtitle: How to install a current version of Ruby on macOS Mojave
tags: [jekyll, macOS, ruby]
image: '/img/ruby-logo.png'
---

[Jekyll](https://jekyllrb.com) requires Ruby 2.4 or higher.
Trying to install Jekyll on my Macbook I noticed that the version shipped with Mojave is 2.3.something.

There are a couple of ways to solve this.

## homebrew

The first one is using [homebrew](https://brew.sh/). Provided that you have installed it before, it is just a command away:

```bash
brew install ruby
```

Don't forget to set the `PATH` environment to make sure that you use the right Ruby version:

```bash
export PATH=/usr/local/opt/ruby/bin:$PATH
ruby -v
ruby 2.6.4p104 (2019-08-28 revision 67798) [x86_64-darwin18]
```

## rbenv

[rbenv](https://github.com/rbenv/rbenv) is a tool commonly used to manage different versions of Ruby, which is quite useful sometimes. Of course it can be installed from homebrew as well:

```bash
brew install rbenv
rbenv init
# Add rbenv init to your bash shell environment
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
```

After that, you can install whatever version of Ruby you need. For example:

```
rbenv install 2.6.3
rbenv global 2.6.3
ruby -v
ruby 2.6.3p62 (2019-04-16 revision 67580)
```

## Installing Jekyll

![jekyll logo](/img/jekyll-logo.png){:class="img-responsive"}

In my case Ruby was installed from brew, so I am running 2.6.4. To install Bundler and Jekyll run:

```
gem install --user-install bundler jekyll
```

Again, be careful with the environment:

```
export PATH=$HOME/.gem/ruby/2.6.0/bin:$PATH
gem env
```

Check that GEM PATHS are ok and you are good to go.

Now move to your shiny Jekyll project folder, run:

```
bundle install
bundle exec jekyll serve --watch
bundle exec jekyll build
```

and you are good to go!
