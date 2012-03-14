Lograge - Taming Rails' Default Request Logging
=======

Lograge is an attempt to bring sanity to Rails' noisy and unusable, unparsable
and, in the context of running multiple processes and servers, unreadable
default logging output. Rails' default approach to log everything is great
during development, it's terrible when running it in production. It pretty much
renders Rails logs useless to me.

Lograge is a work in progress. I appreciate constructive feedback and criticism.
My main goal is to improve Rails' logging and to show people that they don't
need to stick with its defaults anymore if they don't want to.

Instead of trying solving the problem of having multiple lines per request by
switching Rails' logger for something that outputs syslog lines or adds a
request token, Lograge replaces Rails' request logging entirely, reducing the
output per request to a single line with all the important information, removing
all that clutter Rails likes to include and that gets mingled up so nicely when
multiple processes dump their output into a single file.

Instead of having an unparsable amount of logging output like this:

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

you get a single line with all the important information, like this:

```
GET /jobs/833552.json format=json action=jobs#show status=200 duration=58.33 view=40.43 db=15.26
```

The second line is easy to grasp with a single glance and still includes all the
relevant information as simple key-value pairs. The syntax is heavily inspired
by the log output of the Heroku router. It doesn't include any timestamp by
default, instead it assumes you use a proper log formatter instead.

**Installation**

In your Gemfile

```ruby
gem "lograge"
```

Enable it for the relevant environments, e.g. production:

```
# config/environments/production.rb
MyApp::Application.configure do
  config.lograge.enabled = true 
end
```

Done.

**Internals**

Thanks to the notification system that was introduced in Rails 3, replacing the
logging is easy. Lograge unhooks all subscriptions from
`ActionController::LogSubscriber` and `ActionView::LogSubscriber`, and hooks in
its own log subscription, but only listening for two events: `process_action`
and `redirect_to`. It makes sure that only subscriptions from those two classes
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

**What it doesn't do**

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

**License**

MIT. Code extracted from [Travis CI](http://travis-ci.org).
(c) 2012 Mathias Meyer
