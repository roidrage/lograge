[![Build Status](https://travis-ci.org/roidrage/lograge.svg?branch=master)](https://travis-ci.org/roidrage/lograge)
[![Gem Version](https://badge.fury.io/rb/lograge.svg)](http://badge.fury.io/rb/lograge)

Lograge - Taming Rails' Default Request Logging
=======

Lograge is an attempt to bring sanity to Rails' noisy and unusable, unparsable
and, in the context of running multiple processes and servers, unreadable
default logging output. Rails' default approach of logging everything is great
during development, but it's terrible when your code is running in production. It pretty much
renders Rails logs useless to me.

Lograge is a work in progress. I appreciate constructive feedback and criticism.
My main goal is to improve Rails' logging and to show people that they don't
need to stick with its defaults anymore if they don't want to.

LogRage reduces the complexity of Rails logs that have multiple lines per request by replacing
Rails' request logging entirely. By doing so, LogRage reduces the output per request to a single line 
with all the important information, removing all the clutter that Rails likes to include 
and that gets mixed up in confusing ways when multiple processes dump their output into a single file.

Standard Rails logging several lines of logging output for each request, that contain information that may be useful for debugging on your local or development environment but can be confusing in a live environment, like this:

```
Started GET "/" for 127.0.0.1 at 2012-03-10 14:28:14 +0100
Processing by HomeController#index as HTML
  Rendered text template within layouts/application (0.0ms)
  Rendered layouts/_assets.html.erb (2.0ms)
  Rendered layouts/_top.html.erb (2.6ms)
  Rendered layouts/_about.html.erb (0.3ms)
  Rendered layouts/_google_analytics.html.erb (0.4ms)
Completed 200 OK in 79ms (Views: 78.8ms | ActiveRecord: 0.0ms)
```

When you use LogRage, however, you get a log that condenses this to a single line with (hopefully) all the important information, like this:

```
method=GET path=/jobs/833552.json format=json controller=JobsController  action=show status=200 duration=58.33 view=40.43 db=15.26
```

This condensed presents the information as key-value pairs, which should help make clear 
exactly what information is present and, importantly, ensures that it's clear which aspects 
of the log relate to the same request. The syntax is heavily inspired by the log output of 
the Heroku router. LogRage doesn't include a timestamp by default, so I recommend that you 
use a proper log formatter to view the file if you need this information. (However, see below 
for how to add a timestamp if you prefer it.)

## Installation ##

In your Gemfile

```ruby
gem "lograge"
```

Enable it in an initializer or the relevant environment config:

```ruby
# config/initializers/lograge.rb
# OR
# config/environments/production.rb
Rails.application.configure do
  config.lograge.enabled = true
end
```

If you're using Rails 5's API-only mode and inherit from
`ActionController::API`, you must define it as the controller base class which
lograge will patch:

```ruby
# config/initializers/lograge.rb
Rails.application.configure do
  config.lograge.base_controller_class = 'ActionController::API'
end
```

If you use multiple base controller classes in your application, specify an array:

```ruby
# config/initializers/lograge.rb
Rails.application.configure do
  config.lograge.base_controller_class = ['ActionController::API', 'ActionController::Base']
end
```

## Configuration ##

You can add a timestamp to the output log lines by adding a configuraton option as follows:

```ruby
Rails.application.configure do
  config.lograge.enabled = true

  # add time to lograge
  config.lograge.custom_options = lambda do |event|
    { time: Time.now }
  end
end
```

You can keep the original (and verbose) Rails logger by following this configuration:

```ruby
Rails.application.configure do
  config.lograge.keep_original_rails_log = true

  config.lograge.logger = ActiveSupport::Logger.new "#{Rails.root}/log/lograge_#{Rails.env}.log"
end
```

Alternatively, to further clean up your logging, you can tell Lograge to skip log messages
that meet criteria that you set.  You can skip log messages generated from particular controller
actions, or write a custom handler to skip messages based on data in the log event:

```ruby
# config/environments/production.rb
Rails.application.configure do
  config.lograge.enabled = true

  config.lograge.ignore_actions = ['HomeController#index', 'AController#an_action']
  config.lograge.ignore_custom = lambda do |event|
    # return true here if you want to ignore based on the event
  end
end
```

## Custom log variables

You can add a hook to LogRage that will let you add custom data to your logs:

```ruby
# config/environments/staging.rb
Rails.application.configure do
  config.lograge.enabled = true

  # custom_options can be a lambda or hash
  # if it's a lambda then it must return a hash
  config.lograge.custom_options = lambda do |event|
    # capture some specific timing values you are interested in
    {:name => "value", :timing => some_float.round(2), :host => event.payload[:host]}
  end
end
```

You can then add custom variables to your logs by adding them to the `event.payload` hash. This is then processed in the `custom_options` method above. For example:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  def append_info_to_payload(payload)
    super
    payload[:host] = request.host
  end
end
```

Alternatively, you can add a hook for accessing controller methods directly (e.g. `request` and `current_user`).
A hash in this form will be merged into the log data automatically.

```ruby
Rails.application.configure do
  config.lograge.enabled = true

  config.lograge.custom_payload do |controller|
    {
      host: controller.request.host,
      user_id: controller.current_user.try(:id)
    }
  end
end
```

## Set the output format

Lograge supports multiple output formats. The default format is the key-value 
format described above, but the full list is:

```ruby
  Lograge::Formatters::Lines.new
  Lograge::Formatters::Cee.new
  Lograge::Formatters::Graylog2.new
  Lograge::Formatters::KeyValue.new  # default lograge format
  Lograge::Formatters::Json.new
  Lograge::Formatters::Logstash.new
  Lograge::Formatters::LTSV.new
  Lograge::Formatters::Raw.new       # Returns a ruby hash object
```

To generate JSON logs in the json_event format used by [Logstash](http://logstash.net/), 
for example, set the formatter like this:

```ruby
# config/environments/production.rb
Rails.application.configure do
  config.lograge.formatter = Lograge::Formatters::Logstash.new
end
```

*Note:* To use the logstash output, you need to add the additional gem
`logstash-event` to your Gemfile like this:

```ruby
gem "logstash-event"
```

The other formats are available natively, without installing additional gems.

In addition to the predefined formatters, you can manipulate the data yourself by passing
an object which responds to #call:

```ruby
# config/environments/production.rb
Rails.application.configure do
  config.lograge.formatter = ->(data) { "Called #{data[:controller]}" } # data is a ruby hash
end
```

## Internals ##

Thanks to the notification system that was introduced in Rails 3, replacing the
logging is easy. Lograge unhooks all subscriptions from
`ActionController::LogSubscriber` and `ActionView::LogSubscriber`, and hooks in
its own log subscription, but only listening for two events: `process_action`
and `redirect_to` (in case of standard controller logs).
It makes sure that only subscriptions from those two classes
are removed. If you happened to hook in your own, they'll be safe.

Unfortunately, when a redirect is triggered by your application's code,
ActionController fires two events. One for the redirect itself, and another one
when the request is finished. Unfortunately the final event doesn't include the
redirect, so Lograge stores the redirect URL as a thread-local attribute and
refers to it in `process_action`.

The event itself contains most of the relevant information to build up the log
line, including view processing and database access times.

While the LogSubscribers encapsulate most logging pretty nicely, there are still
two lines that show up no matter what. The first line that's output for every
Rails request, you know, this one:

```
Started GET "/" for 127.0.0.1 at 2012-03-12 17:10:10 +0100
```

And the verbose output coming from rack-cache:

```
cache: [GET /] miss
```

Both are independent of the LogSubscribers, and both need to be shut up using
different means.

For the first one, the starting line of every Rails request log, Lograge
replaces code in `Rails::Rack::Logger` to remove that particular log line. It's
not great, but it's just another unnecessary output and would still clutter the
log files. Maybe a future version of Rails will make this log line an event as
well.

To remove rack-cache's output (which is only enabled if caching in Rails is
enabled), Lograge disables verbosity for rack-cache, which is unfortunately
enabled by default.

There, a single line per request. Beautiful.

## Action Cable ##

Starting with version 0.11.0, Lograge introduced support for Action Cable logs.
This proved to be a particular challenge since the framework code is littered
with multiple (and seemingly random) logger calls in a number of internal classes.
In order to deal with it, the default Action Cable logger was silenced.
As a consequence, calling logger e.g. in user-defined `Connection` or `Channel`
classes has no effect - `Rails.logger` (or any other logger instance)
has to be used instead.

Additionally, while standard controller logs rely on `process_action` and `redirect_to`
instrumentations only, Action Cable messages are generated from multiple events:
`perform_action`, `subscribe`, `unsubscribe`, `connect`, and `disconnect`.
`perform_action` is the only one included in the actual Action Cable code and
others have been added by monkey patching [`ActionCable::Channel::Base`](https://github.com/roidrage/lograge/blob/master/lib/lograge/rails_ext/action_cable/channel/base.rb) and
[`ActionCable::Connection::Base`](https://github.com/roidrage/lograge/blob/master/lib/lograge/rails_ext/action_cable/connection/base.rb) classes.

## What it doesn't do ##

Lograge is opinionated, very opinionated. If the stuff below doesn't suit your
needs, it may not be for you.

Lograge removes ActionView logging, which also includes rendering times for
partials. If you're into those, Lograge is probably not for you. In my honest
opinion, those rendering times don't belong in the log file, they should be
collected in a system like New Relic, Librato Metrics or some other metrics
service that allows graphing rendering percentiles. I assume this for everything
that represents a moving target. That kind of data is better off being
visualized in graphs than dumped (and ignored) in a log file.

Lograge doesn't yet log the request parameters. This is something I'm actively
contemplating, mainly because I want to find a good way to include them, a way
that fits in with the general spirit of the log output generated by Lograge.
However, the payload does already contain the params hash, so you can easily
add it in manually using `custom_options`:

```ruby
# production.rb
YourApp::Application.configure do
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    exceptions = %w(controller action format id)
    {
      params: event.payload[:params].except(*exceptions)
    }
  end
end
```

## FAQ ##

### Logging errors / exceptions ###

Our first recommendation is that you use exception tracking services built for
purpose ;)

If you absolutely *must* log exceptions in the single-line format, you can
do something similar to this example:

```ruby
# config/environments/production.rb

YourApp::Application.configure do
  config.lograge.enabled = true
  config.lograge.custom_options = lambda do |event|
    {
      exception: event.payload[:exception], # ["ExceptionClass", "the message"]
      exception_object: event.payload[:exception_object] # the exception instance
    }
  end
end
```

The `:exception` is just the basic class and message whereas the
`:exception_object` is the actual exception instance. You can use both /
either. Be mindful when including this, you will probably want to cherry-pick
particular attributes and almost definitely want to `join` the `backtrace` into
something without newline characters.

### Handle ActionController::RoutingError ###

Add a ` get '*unmatched_route', to: 'application#route_not_found'` rule to the end of your `routes.rb`
Then add a new controller action in your `application_controller.rb`.

```ruby
def route_not_found
  render 'error_pages/404', status: :not_found
end
```

[#146](https://github.com/roidrage/lograge/issues/146)


## Contributing ##

See the CONTRIBUTING.md file for further information.

## License ##

MIT. Code extracted from [Travis CI](http://travis-ci.org).

(c) 2014 Mathias Meyer

See `LICENSE.txt` for details.
