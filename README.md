# Context.IO

* [Homepage](https://github.com/contextio/contextio-ruby#readme)
* [API Documentation](http://context.io/docs/2.0/)
* [Gem Documentation](http://rubydoc.info/gems/contextio/frames)
* [Sign Up](http://context.io)


## Description

Provides a Ruby interface to [Context.IO](http://context.io). The general design
was inspired by the wonderful [aws-sdk](https://github.com/aws/aws-sdk-ruby)
gem. You start with an object that represents your account with Context.IO and
then you deal with collections within that going forward (see the [Usage
section](#usage)).


## A Note On Method Names

If you're looking at the [Context.IO docs](http://context.io/docs/2.0/), it is
important to note that there are some attributes that've been renamed to be a
bit more Ruby-friendly. In general, if the API returns a number meant to be
seconds-from-epoch, then it's been converted to return a `Time` (e.g. `updated`
has changed to `updated_at`) and a boolean has converted to something with a `?`
at the end (e.g. `HasChildren` and `initial_import_finished` are `has_children?`
and `initial_import_finished?`, respectively). See the [gem
docs](http://rubydoc.info/gems/contextio/frames) for a specific class when in
doubt.


## Install

    $ gem install contextio

Or, of course, put this in your Gemfile:

    gem 'contextio'


## Version Numbers

This gem adheres to [SemVer](http://semver.org/). So you should be pretty safe
upgrading from 1.0.0 to 1.9.9. Whatever as long as the major version doesn't
bump. When the major version bumps, be warned; upgrading will take some kind of
effort.


## Usage

```ruby
require 'contextio'

contextio = ContextIO.new('your_api_key', 'your_api_secret')

account = contextio.accounts.where(email: 'some@email.com').first

account.email_addresses # ['some@email.com', 'another@email.com']
account.first_name # 'Bruno'
account.suspended? # False

account.messages.where(folder: '\Drafts').each do |m|
  puts m.subject
end
```

To grab an account you have just authenticated and have the token for, you can 
just look it up in the Accounts collection using the connect_tokens attribute.

```ruby
require 'contextio'

contextio = ContextIO.new('your_api_key', 'your_api_secret')
account = contextio.accounts.where(connect_tokens: token).first
```

To grab some object you already know the primary key for, you'll use the `[]`
method like you would for a `Hash` or `Array`. This is most helpful for
accounts, but works for any resource collection.

```ruby
require 'contextio'

contextio = ContextIO.new('your_api_key', 'your_api_secret')

account = contextio.accounts[some_account_id]
message = account.messages[some_message_id]
```


### On Laziness

This gem is architected to be as lazy as possible. It won't make an HTTP request
until you ask it for some data that it knows it needs to fetch. An example might
be illustrative:

```ruby
require 'contextio'

contextio = ContextIO.new('your_api_key', 'your_api_secret')

account = contextio.accounts['1234'] # No request made here.
account.last_name # Request made here.
account.first_name # No request made here.
```

Note that when it made the request, it stored the data it got back, which
included the first name, so it didn't need to make a second request. Asking for
the value of any attribute listed in the [gem
docs](http://rubydoc.info/gems/contextio/frames) will trigger the request.


### On Requests and Methods

There are some consistent mappings between the requests documented in the [API
docs](http://context.io/docs/2.0/) and the methods implemented in the gem.

**For collections of resources:**

* the object its self sort of represents the collection-level `GET` (treat it
  like any other `Enumerable`).
* `#where` is how you set up the filters on the collection-level `GET`.
* `#create` maps to the collection-level `POST` or `PUT`, as appropriate.
* `#[]` maps to the individual-level `GET`, but (as mentioned above) is lazy.

**For individual resources**

* the object its self sort of represents the individual-level `GET` (but see
  `#[]` above).
* `#delete` maps to the individual-level `DELETE`.
* `#update` maps to the individual-level `POST` (except in a few cases like
  `Message#copy_to` and `Message#move_to`).


## Contributing

Help is gladly welcomed. If you have a feature you'd like to add, it's much more
likely to get in (or get in faster) the closer you stick to these steps:

1. Open an Issue to talk about it. We can discuss whether it's the right
  direction or maybe help track down a bug, etc.
1. Fork the project, and make a branch to work on your feature/fix. Master is
  where you'll want to start from.
1. Turn the Issue into a Pull Request. There are several ways to do this, but
  [hub](https://github.com/defunkt/hub) is probably the easiest.
1. Make sure your Pull Request includes tests.

If you don't know how to fix something, even just a Pull Request that includes a
failing test can be helpful. If in doubt, make an Issue to discuss.


## Copyright

Copyright (c) 2012 Context.IO

This gem is distributed under the MIT License. See LICENSE.md for details.
