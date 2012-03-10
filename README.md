Lograge - Taming Rails' Default Request Logging
=======

Lograge is an attempt to bring sanity to Rails' noisy and unusable, unparsable
and, in the context of running multiple processes and servers, unreadable
default logging output.

Instead of trying solving the problem of having multiple lines per request by
switching Rails' logger for something that outputs syslog lines or adds a
request token, Lograge replaces Rails' request logging entirely, reducing the
output per request to a single line with all the important information, removing
all that clutter Rails likes to include and that gets mingled up so nicely when
multiple processes dump their output into a single file

Instead of having an unparsable amount of logging output like this:

```
```

you get a single line with all the important information, like this:

```
GET /jobs/833552.json format=json action=jobs#show status=200 duration=58.33 view=40.43 db=15.26
```

The second line is easy to grasp with a single glance and still includes all the
relevant information as simple key-value pairs. The syntax is heavily inspired
by the log output of the Heroku router.

**Internals**

Thanks to the notification system that was introduced in Rails 3, replacing the
logging is easy. Lograge unhooks all subscriptions from
`ActionController::LogSubscriber` and `ActionView::LogSubscriber`, and hooks in
its own log subscription, but only listening for two events: `process\_action`
and `redirect\_to`. It makes sure that only subscriptions from those two classes
are removed. If you happened to hook in your own, they'll be safe.

Unfortunately, when a redirect is triggered by your application's code,
ActionController fires two events. One for the redirect itself, and another one
when the request is finished. Unfortunately the final event doesn't include the
redirect, so Lograge stores the redirect URL as a thread-local attribute and
refers to it in `process\_action`.

The event itself contains most of the relevant information to build up the log
line, including view processing and database access times.

While the LogSubscribers encapsulate most logging pretty nicely, there are still
two lines that show up no matter what. The first line that's output for every
Rails request, you know, this one:

And the verbose output coming from rack-cache:

Both are independent of the LogSubscribers, and both need to be shut up using
different means.

For the first one, the starting line of every Rails request log, Lograge removes
the Rails::Rack::Logger middleware from the stack. This may look like a drastic
means, but all the middleware does is log that useless line, log exceptions, and
create a request transaction id (Rails 3.2). A future version may replace with
its own middleware, that simply removes the log line.

To remove rack-cache's output (which is only enabled if caching in Rails is
enabled), Lograge disables verbosity for rack-cache, which is unfortunately
enabled by default.

There, a single line per request. Beautiful.

**What it doesn't do**

Lograge removes ActionView logging, which also includes rendering times for
partials. If you're into those, Lograge is probably not for you. In my honest
opinion, those rendering times don't belong in the log file, they should be
collected in a system like New Relic, Librato Metrics or some other metrics
service that allows graphing rendering percentiles.
