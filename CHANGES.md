# Changes

## 2.1.0

* Lazy Folder access, and allow indexing folder collection by name

##2.0.0

* Limit Faraday to no retries on requests, update version of faraday -Bonnie Mattson

## 1.8.0

* loosened faraday dependency - Michael Bernstein
* Moved `ContextIO::Message#thread` from private to public, and also changed the
  method to return json data instead of creating a `ContextIO::Thread` object. - Eric Pinzur
* Add 'references' to lazy_attributes in message.rb - Dylan Stamat
* Add remove_folder method to the Message class in message.rb. - Brandon Chow
* Hotfix the FolderCollection class's create method in folder_collection.rb : the optional delim parameter causes the api call to break. - Brandon Chow
* Include ContextIO::API::Resource in EmailAddress class to allow for resource url calls. - Brandon Chow

## 1.7.2

* Improve error handling for better trouble shooting. - Ben Hamill

## 1.7.1

* Fix bug in `ContextIO::Message#set_flags` that was failing, and also fixes the
  wrong api url it was trying to call. - [Paul Bonaud](https://github.com/popox)
* Spruce up README, and add CONTRIBUTING and RELEASING guides. - Ben Hamill

## 1.7.0

* Further README updates for clarity. - Johnny Goodman
* Convert to Faraday back-end for making requests. - Ben Hamill
* Fix bug in `ContextIO::Source` that caused the `sync_data` method to always
  fail. - Dominik Gehl
* Improve documentation for `ContextIO::API::ResourceCollection#where` to
  include a link to the general API documentation. - Chris McNair

## 1.6.0

* Add `version` and `base_url` instance variables to API. - Dominik Gehl
* Don't try to JSON parse raw attachments. - Dominik Gehl
* Use symbols for options internally to avoid OAuth gem failure. - Ben Hamill
* Add `in_reply_to` to `Message`'s lazy attributes. - Asa Wilson
* Fix bug where `Hash`es with mixed `String`/`Symbol` keys would cause the OAuth
  gem to explode. - Ben Hamill
* Add missing files association to `Message` class. - Ben Hamill
* Add a ton of examples to the README to help new users. - Johnny Goodman

## 1.5.0

* Make `Source#sync!` and `Account#sync!` take an options hash that will be
  passed as parameters in the resulting HTTP request. This is just to aid in
  debugging. - Ben Hamill

## 1.4.0

* Normalize key names from the API to be valid Ruby variable names. - Ben Hamill
* Fix how `Folder` objects create their associated `MessageCollection` objects,
  specifically with respect to passing around the handle to an appropriate
  `Account` object. - Ben Hamill
* Convenience methods: `Message#to`,`#bcc`, `#cc` and `#reply_to`. - Aubrey
  Holland

## 1.3.0

* Add sugar `Message#from` method. - Andrew Harrison
* Fix bug related to `nil` being passed around for associations which caused the
  association not to be filled with data from the API. - Ben Hamill

## 1.2.4

* Add link to gem documentation to top of README. - Ben Hamill
* Expand README to clarify gem usage. - Ben Hamill
* Make `ResourceCollection#[]` correctly pass down the "owning" associated
  object to instances created with it. - Ben Hamill
* Work around the OAuth gem handling PUT request signing a bit oddly. - Ben
  Hamill

## 1.2.3

* Fix infinite loop in ConnectToken URL building. - Ben Hamill

## 1.2.2

* Fix `PUT` and `POST` parameter submission. - Ben Hamill
* Added missing `server` argument to `SourceCollection.create`. - Dominik Gehl
* Moved erroneous `File.sync_data` and `File.sync!` over to `Source` where it
  belonged in the first place. - Bram Plessers

## 1.2.1

* Fixed syntax error typo in previous release. - Geoff Longman

## 1.2.0

* Add `#empty?` and `#size` to resource collections so you can treat them even
  *more* like arrays! - Geoff Longman

## 1.1.0

* Allow passing options to `OAuth` through the gem. Notably, `:timeout` and
  `:open_timeout`. - Geoff Longman

## 1.0.1

* Updated homepage link in README distributed with the gem. - Ben Hamill
