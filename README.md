# Context.IO

* [Homepage](https://github.com/contextio/contextio-ruby#readme)
* [API Documentation](http://context.io/docs/2.0/)
* [Gem Documentation](http://rubydoc.info/gems/contextio/frames)
* [API Explorer](https://console.context.io/#explore)
* [Sign Up](http://context.io)


## Description

Provides a Ruby interface to [Context.IO](http://context.io). The general design
was inspired by the wonderful [aws-sdk](https://github.com/aws/aws-sdk-ruby)
gem. You start with an object that represents your account with Context.IO and
then you deal with collections within that going forward (see the [Quick Start
section](#quick start)).


## Install

    $ gem install contextio

Or, of course, put this in your Gemfile:

    gem 'contextio'


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


## Version Numbers

This gem adheres to [SemVer](http://semver.org/). So you should be pretty safe
upgrading from 1.0.0 to 1.9.9. Whatever as long as the major version doesn't
bump. When the major version bumps, be warned; upgrading will take some kind of
effort.


## Examples

### Quick Start

Print the subject of the first five messages in the some@email.com account.

```ruby
require 'contextio'

contextio = ContextIO.new('your_api_key', 'your_api_secret')

account = contextio.accounts.where(email: 'some@email.com').first

account.messages.where(limit: 5).each do |message|
  puts message.subject
end
```


### Primary Key Queries

To grab some object you already know the primary key for, you'll use the `[]` 
method like you would for a `Hash` or `Array`. 

This is most helpful for accounts, but works for any resource collection.

```ruby
require 'contextio'

contextio = ContextIO.new('your_api_key', 'your_api_secret')

some_account_id = "exampleaccountid12345678"

account = contextio.accounts[some_account_id]
message = account.messages[some_message_id]
```


#### Message By Key

```ruby
message = account.messages[some_message_id]

message.message_id 		#=> "examplemessageid12345678"
message.subject 			#=> "My Email's Subject"
message.from.class 		#=> Hash
message.from['email'] #=> "some@email.com"
message.from['name'] 	#=> "John Doe"

message.delete #=> true
```

Body content must be accessed through each body part (eg: html, text, etc.). 
Context.io does not store body content and so each call will source it 
directly from the mail box associated with the account. This will be slow 
relative to the context.io API. 

You can specify and receive a single body content type. 

```ruby
message = account.messages[some_message_id]

message_part = message.body_parts.where(type: 'text/plain').first

message_part.class 		#=> ContextIO::BodyPart
message_part.type 		#=> "text/plain"
message_part.content #=> "body content of text/plain body_part"
```

You can determine how many body parts are available and iterate over each one.

```ruby
message = account.messages[some_message_id]

message.body_parts.class #=> ContextIO::BodyPartCollection
message.body_parts.count #=> 2

message.body_parts.each do |part|
	puts part.class #=> ContextIO::BodyPart
	puts part.type #=> "text/html"
	puts part.content #=> "body content of text/html body_part" 
end
```


#### Account By Key

You can specify an account id and get back information about that account.

```ruby
account = contextio.accounts[some_account_id]

account.email_addresses #=> ['some@email.com', 'another@email.com']
account.id 							#=> "exampleaccountid12345678"
account.first_name 			#=> "Bruno"
account.suspended? 			#=> False
```


### Message Collections

#### Query Basics

Queries to Messages return ContextIO::MessageCollection objects which can be 
iterated on. 

The `where` method allows you to refine search results based on [available filters](http://context.io/docs/2.0/accounts/messages#get). 

```ruby
#the 25 most recent messages by default, you can specify a higher limit
account.messages 

#the 50 most recent messages
account.messages.where(limit: 50) 

#recent messages sent to the account by some@email.com
account.messages.where(from: 'some@email.com') 

#multiple parameters accepted in hash format
account.messages.where(from: 'some@email.com', subject: 'hello') 

#regexp accepted as a string like '/regexp/'
account.messages.where(from: 'some@email.com', subject: '/h.llo/') 

#regexp options are supported, the /i case insensitive is often useful
account.messages.where(from: 'some@email.com', subject: '/h.llo/i') 
```


#### Querying Dates

Pass dates in to message queries as Unix Epoch integers.

```ruby
require 'active_support/all'

account.messages.where(date_before: 3.hours.ago.to_i, date_after: 5.hours.ago.to_i).each do |message|
  puts "(#{message.date}) #{message.subject}"
end
```

You can mix date and non-date parameters.

```ruby
account.messages.where(
  date_before: 3.days.ago.to_i,
  date_after: 4.weeks.ago.to_i,
  subject: 'subject of email',
  from: 'foo@email.com'
)
```


### Individual Messages

#### Message Basics

```ruby
account.messages.where(limit: 1).class # ContextIO::MessageCollection 

message = account.messages.where(limit: 1).first 

message.class 	#=> ContextIO::Message
message.subject #=> "subject of message"
message.from 		#=> {"email"=>"some@email.com", "name"=>"John Doe"}
message.to 			#=> [{"email"=>"some@email.com", "name"=>"'John Doe'"}, {"email"=>"another@email.com", "name"=>"Jeff Mangum"}]
```

#### Message Dates

##### received_at

`received_at` is the time when your IMAP account records the message 
having arrived. It is returned as a Time object. 

```ruby
m.received_at				#=> 2013-04-19 08:12:04 -0500
m.received_at.class #=> Time
```

##### indexed_at

`indexed_at` is the time when the message was processed and indexed 
by the Context.io sync process.

```ruby
m.indexed_at #=> 2013-04-29 01:14:39 -0500
m.received_at.class #=> Time
```

##### date

A message's date is set by the sender, extracted from the message's Date 
header and is returned as a FixNum which can be converted into a Time 
object. 

```ruby
message.date 								#=> 1361828599
Time.at(message.date) 			#=> 2013-04-19 08:11:33 -0500
Time.at(message.date).class #=> Time
```

`message.date` is not reliable as it is easily spoofed. While it is made
available, `received_at` and `indexed_at` are better choices.


#### Messages with Body Data

By default, Context.io's API does not return message queries with body data. 

You can include the body attribute in each individual message returned by
adding `include_body: 1` to your `messages.where` query options.

```ruby
account.messages.where(include_body: 1, limit: 1).each do |message|
	puts "#{message.subject} #{message.date} #{message.body[0]['content']}"
end
```

Emails that contain two or more body parts are called [multipart messages](https://en.wikipedia.org/wiki/MIME#Alternative). 

'text/plain' and 'text/html' are common body part types for multipart
messages.

In the case a user is viewing email in a client that does not support HTML
markup, the 'text/plain' body part type will render instead. 

If you are working with multipart messages, you may want to check each 
body part's content in turn. 

```ruby
account.messages.where(include_body: 1, limit: 1).each do |message|
	message.body_parts.each do |body_part|
		puts body_part.content
	end
end
```

The include_body method queries the source IMAP box directly, which results 
in slower return times. 


### Files 

#### Files Per Message ID

```ruby
message = account.messages[message_id]

message.files.class 									#=> ContextIO::FileCollection
message.files.count 									#=> 2
message.files.map { |f| f.file_name } #=> ["at_icon.png", "argyle_slides.png"]
message.files.first.resource_url 			#=> https://contextio_to_s3_redirect_url.io
```

The file['resource_url'] url is a S3 backed temporary link. It is intended 
to be used promptly after being called. Do not store off this link. Instead, 
store off the message_id and request on demand.


### On Laziness

This gem is architected to be as lazy as possible. It won't make an HTTP request
until you ask it for some data that it knows it needs to fetch. An example might
be illustrative:

```ruby
require 'contextio'

contextio = ContextIO.new('your_api_key', 'your_api_secret')

account = contextio.accounts['exampleaccountid12345678'] # No request made here.
account.last_name # Request made here.
account.first_name # No request made here.
```

Note that when it made the request, it stored the data it got back, which
included the first name, so it didn't need to make a second request. Asking for
the value of any attribute listed in the [gem
docs](http://rubydoc.info/gems/contextio/frames) will trigger the request.


### On Requests and Methods

There are some consistent mappings between the requests documented in the 
[API docs](http://context.io/docs/2.0/) and the methods implemented in the gem.

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
1. Bonus points if your Pull Request updates `CHANGES.md` to include a summary
   of your changes and your name like the other entries. If the last entry is
   the last release, add a new `## Unreleased` heading.

If you don't know how to fix something, even just a Pull Request that includes a
failing test can be helpful. If in doubt, make an Issue to discuss.


## Copyright

Copyright (c) 2012-2013 Context.IO

This gem is distributed under the MIT License. See LICENSE.md for details.
