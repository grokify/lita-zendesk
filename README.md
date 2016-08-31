Lita Zendesk Handler
====================

[![Gem Version][gem-version-svg]][gem-version-link]
[![Build Status][build-status-svg]][build-status-link]
[![Coverage Status][coverage-status-svg]][coverage-status-link]
[![Dependency Status][dependency-status-svg]][dependency-status-link]
[![Code Climate][codeclimate-status-svg]][codeclimate-status-link]
[![Scrutinizer Code Quality][scrutinizer-status-svg]][scrutinizer-status-link]
[![Downloads][downloads-svg]][downloads-link]
[![Docs][docs-rubydoc-svg]][docs-rubydoc-link]
[![License][license-svg]][license-link]

`lita-zendesk` is an handler for [Lita](https://www.lita.io/) that allows you to use the robot with [Zendesk](https://zendesk.com/) ticket queries.

## Installation

Add `lita-zendesk` to your Lita instance's Gemfile:

``` ruby
gem "lita-zendesk"
```

## Configuration

Both Token and Password authentication are supported using the `config.handlers.zendesk.auth_type` property which can be set to `token` or `password`.

``` ruby
Lita.configure do |config|

  # Zendesk user info
  config.handlers.zendesk.subdomain = 'my_zendesk_subdomain'
  config.handlers.zendesk.auth_type = 'password'   # set to 'password' or 'token'
  config.handlers.zendesk.user = 'my_zendesk_user' # required for both 'password' and 'token'
  config.handlers.zendesk.password = 'my_zendesk_password'
  config.handlers.zendesk.token = 'my_zendesk_token'

end
```

## Usage

`zd` or `zendesk` both work for signaling the handler.

```
Lita > @lita help
Lita: zd connection - returns information on the Zendesk connection
Lita: zd search tickets <QUERY> - returns search results
Lita: zd tickets - returns the total count of all unsolved tickets
Lita: zd all tickets - returns the count of all tickets
Lita: zd pending tickets - returns a count of tickets that are pending
Lita: zd new tickets - returns the count of all new (unassigned) tickets
Lita: zd escalated tickets - returns a count of tickets with escalated tag that are open or pending
Lita: zd open tickets - returns the count of all open tickets
Lita: zd on hold tickets - returns the count of all on hold tickets
Lita: zd list tickets - returns a list of unsolved tickets
Lita: zd list all tickets - returns a list of all tickets
Lita: zd list pending tickets - returns a list of pending tickets
Lita: zd list new tickets - returns a list of new tickets
Lita: zd list esclated tickets - returns a list of escalated tickets
Lita: zd list open tickets - returns a list of open tickets
Lita: zd list onhold tickets - returns a list of on hold tickets
Lita: zd ticket <ID> - returns information about the specified ticket
```

## Change Log

See [CHANGELOG.md](CHANGELOG.md)

## Links

Project Repo

* https://github.com/grokify/lita-zendesk

Lita

* https://www.lita.io/

Ported and adapted from `hubot-scripts/zendesk.coffee`:

* https://github.com/github/hubot-scripts/blob/master/src/scripts/zendesk.coffee

## Contributing

1. Fork it ( http://github.com/grokify/lita-zendesk/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Lita Zendesk Handler is available under the MIT license. See [LICENSE.txt](LICENSE.txt) for details.

Lita Zendesk Handler &copy; 2016 by John Wang

 [gem-version-svg]: https://badge.fury.io/rb/lita-zendesk.svg
 [gem-version-link]: http://badge.fury.io/rb/lita-zendesk
 [downloads-svg]: http://ruby-gem-downloads-badge.herokuapp.com/lita-zendesk
 [downloads-link]: https://rubygems.org/gems/lita-zendesk
 [build-status-svg]: https://api.travis-ci.org/grokify/lita-zendesk.svg?branch=master
 [build-status-link]: https://travis-ci.org/grokify/lita-zendesk
 [coverage-status-svg]: https://coveralls.io/repos/grokify/lita-zendesk/badge.svg?branch=master
 [coverage-status-link]: https://coveralls.io/r/grokify/lita-zendesk?branch=master
 [dependency-status-svg]: https://gemnasium.com/grokify/lita-zendesk.svg
 [dependency-status-link]: https://gemnasium.com/grokify/lita-zendesk
 [codeclimate-status-svg]: https://codeclimate.com/github/grokify/lita-zendesk/badges/gpa.svg
 [codeclimate-status-link]: https://codeclimate.com/github/grokify/lita-zendesk
 [scrutinizer-status-svg]: https://scrutinizer-ci.com/g/grokify/lita-zendesk/badges/quality-score.png?b=master
 [scrutinizer-status-link]: https://scrutinizer-ci.com/g/grokify/lita-zendesk/?branch=master
 [docs-rubydoc-svg]: https://img.shields.io/badge/docs-rubydoc-blue.svg
 [docs-rubydoc-link]: http://www.rubydoc.info/gems/lita-zendesk/
 [license-svg]: https://img.shields.io/badge/license-MIT-blue.svg
 [license-link]: https://github.com/grokify/lita-zendesk/blob/master/LICENSE.txt
