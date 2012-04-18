# Redistat [![Build Status](https://secure.travis-ci.org/jimeh/redistat.png)](http://travis-ci.org/jimeh/redistat)

A Redis-backed statistics storage and querying library written in Ruby.

Redistat was originally created to replace a small hacked together statistics
collection solution which was MySQL-based. When I started I had a short list
of requirements:

* Store and increment/decrement integer values (counters, etc)
* Up to the second statistics available at all times
* Screamingly fast

Redis fits perfectly with all of these requirements. It has atomic operations
like increment, and it's lightning fast, meaning if the data is structured
well, the initial stats reporting call will store data in a format that's
instantly retrievable just as fast.

## Installation

    gem install redistat

If you are using Ruby 1.8.x, it's recommended you also install the
`SystemTimer` gem, as the Redis gem will otherwise complain.

## Usage (Crash Course)

view\_stats.rb:

```ruby
require 'redistat'

class ViewStats
  include Redistat::Model
end

# if using Redistat in multiple threads set this
# somewhere in the beginning of the execution stack
Redistat.thread_safe = true
```


### Simple Example

Store:

```ruby
ViewStats.store('hello', {:world => 4})
ViewStats.store('hello', {:world => 2}, 2.hours.ago)
```

Fetch:

```ruby
ViewStats.find('hello', 1.hour.ago, 1.hour.from_now).all
  #=> [{'world' => 4}]
ViewStats.find('hello', 1.hour.ago, 1.hour.from_now).total
  #=> {'world' => 4}
ViewStats.find('hello', 3.hour.ago, 1.hour.from_now).total
  #=> {'world' => 6}
```


### Advanced Example

Store page view on product #44 from Chrome 11:

```ruby
ViewStats.store('views/product/44', {'count/chrome/11' => 1})
```

Fetch product #44 stats:

```ruby
ViewStats.find('views/product/44', 23.hours.ago, 1.hour.from_now).total
  #=> { 'count' => 1, 'count/chrome' => 1, 'count/chrome/11' => 1 }
```

Store a page view on product #32 from Firefox 3:

```ruby
ViewStats.store('views/product/32', {'count/firefox/3' => 1})
```

Fetch product #32 stats:

```ruby
ViewStats.find('views/product/32', 23.hours.ago, 1.hour.from_now).total
  #=> { 'count' => 1, 'count/firefox' => 1, 'count/firefox/3' => 1 }
```

Fetch stats for all products:

```ruby
ViewStats.find('views/product', 23.hours.ago, 1.hour.from_now).total
  #=> { 'count'           => 2,
  #     'count/chrome'    => 1,
  #     'count/chrome/11' => 1,
  #     'count/firefox'   => 1,
  #     'count/firefox/3' => 1 }
```

Store a 404 error view:

```ruby
ViewStats.store('views/error/404', {'count/chrome/9' => 1})
```

Fetch stats for all views across the board:

```ruby
ViewStats.find('views', 23.hours.ago, 1.hour.from_now).total
  #=> { 'count'           => 3,
  #     'count/chrome'    => 2,
  #     'count/chrome/9'  => 1,
  #     'count/chrome/11' => 1,
  #     'count/firefox'   => 1,
  #     'count/firefox/3' => 1 }
```

Fetch list of products known to Redistat:

```ruby
finder = ViewStats.find('views/product', 23.hours.ago, 1.hour.from_now)
finder.children.map { |child| child.label.me }
  #=> [ "32", "44" ]
finder.children.map { |child| child.label.to_s }
  #=> [ "views/products/32", "views/products/44" ]
finder.children.map { |child| child.total }
  #=> [ { "count" => 1, "count/firefox" => 1, "count/firefox/3" => 1 },
  #     { "count" => 1, "count/chrome"  => 1, "count/chrome/11" => 1 } ]
```


## Terminology

### Scope

A type of global-namespace for storing data. When using the `Redistat::Model`
wrapper, the scope is automatically set to the class name. In the examples
above, the scope is `ViewStats`. Can be overridden by calling the `#scope`
class method on your model class.

### Label

Identifier string to separate different types and groups of statistics from
each other. The first argument of the `#store`, `#find`, and `#fetch` methods
is the label that you're storing to, or fetching from.

Labels support multiple grouping levels by splitting the label string with `/`
and storing the same stats for each level. For example, when storing data to a
label called `views/product/44`, the data is stored for the label you specify,
and also for `views/product` and `views`. You may also configure a different 
group separator using the `Redistat.group_separator` option. For example:

```ruby
Redistat.group_separator = '|'
```

A word of caution: Don't use a crazy number of group levels. As two levels
causes twice as many `hincrby` calls to Redis as not using the grouping
feature. Hence using 10 grouping levels, causes 10 times as many write calls
to Redis.

### Input Statistics Data

You provide Redistat with the data you want to store using a Ruby Hash. This
data is then stored in a corresponding Redis hash with identical key/field
names.

Key names in the hash also support grouping features similar to those
available for Labels. Again, the more levels you use, the more write calls to
Redis, so avoid using 10-15 levels.

### Depth (Storage Accuracy)

Define how accurately data should be stored, and how accurately it's looked up
when fetching it again. By default Redistat uses a depth value of `:hour`,
which means it's impossible to separate two events which were stored at 10:18
and 10:23. In Redis they are both stored within a date key of `2011031610`.

You can set depth within your model using the `#depth` class method. Available
depths are: `:year`, `:month`, `:day`, `:hour`, `:min`, `:sec`

### Time Ranges

When you fetch data, you need to specify a start and an end time. The
selection behavior can seem a bit weird at first when, but makes sense when
you understand how Redistat works internally.

For example, if we are using a Depth value of `:hour`, and we trigger a fetch
call starting at `1.hour.ago` (13:34), till `Time.now` (14:34), only stats
from 13:00:00 till 13:59:59 are returned, as they were all stored within the
key for the 13th hour. If both 13:00 and 14:00 was returned, you would get
results from two whole hours. Hence if you want up to the second data, use an
end time of `1.hour.from_now`.

### The Finder Object

Calling the `#find` method on a Redistat model class returns a
`Redistat::Finder` object. The finder is a lazy-loaded gateway to your
data. Meaning you can create a new finder, and modify instantiated finder's
label, scope, dates, and more. It does not call Redis and fetch the data until
you call `#total`, `#all`, `#map`, `#each`, or `#each_with_index` on the
finder.

This section does need further expanding as there's a lot to cover when it
comes to the finder.


## Key Expiry

Support for expiring keys from Redis is available, allowing you too keep
varying levels of details for X period of time. This allows you easily keep
things nice and tidy by only storing varying levels detailed stats only for as
long as you need.

In the below example we define how long Redis keys for varying depths are
stored. Second by second stats are available for 10 minutes, minute by minute
stats for 6 hours, hourly stats for 3 months, daily stats for 2 years, and
yearly stats are retained forever.

```ruby
class ViewStats
  include Redistat::Model

  depth :sec

  expire \
    :sec => 10.minutes.to_i,
    :min => 6.hours.to_i,
    :hour => 3.months.to_i,
    :day => 2.years.to_i
end
```

Keep in mind that when storing stats for a custom date in the past for
example, the expiry time for the keys will be relative to now. The values you
specify are simply passed to the `Redis#expire` method.


## Internals

### Storing / Writing

Redistat stores all data into a Redis hash keys. The Redis key name the used
consists of three parts. The scope, label, and datetime:

    {scope}/{label}:{datetime}

For example, this...

```ruby
ViewStats.store('views/product/44', {'count/chrome/11' => 1})
```

...would store the follow hash of data...

```ruby
{ 'count' => 1, 'count/chrome' => 1, 'count/chrome/11' => 1 }
```

...to all 12 of these Redis hash keys...

    ViewStats/views:2011
    ViewStats/views:201103
    ViewStats/views:20110315
    ViewStats/views:2011031510
    ViewStats/views/product:2011
    ViewStats/views/product:201103
    ViewStats/views/product:20110315
    ViewStats/views/product:2011031510
    ViewStats/views/product/44:2011
    ViewStats/views/product/44:201103
    ViewStats/views/product/44:20110315
    ViewStats/views/product/44:2011031510

...by creating the Redis key, and/or hash field if needed, otherwise it simply
increments the already existing data.

It would also create the following Redis sets to keep track of which child
labels are available:

    ViewStats.label_index:
    ViewStats.label_index:views
    ViewStats.label_index:views/product

It should now be more obvious to you why you should think about how you use
the grouping capabilities so you don't go crazy and use 10-15 levels. Storing
is done through Redis' `hincrby` call, which only supports a single key/field
combo. Meaning the above example would call `hincrby` a total of 36 times to
store the data, and `sadd` a total of 3 times to ensure the label index is
accurate. 39 calls is however not a problem for Redis, most calls happen in
less than 0.15ms (0.00015 seconds) on my local machine.


### Fetching / Reading

By default when fetching statistics, Redistat will figure out how to do the
least number of reads from Redis. First it checks how long range you're
fetching. If whole days, months or years for example fit within the start and
end dates specified, it will fetch the one key for the day/month/year in
question. It further drills down to the smaller units.

It is also intelligent enough to not fetch each day from 3-31 of a month,
instead it would fetch the data for the whole month and the first two days,
which are then removed from the summary of the whole month. This means three
calls to `hgetall` instead of 29 if each whole day was fetched.

### Buffer

The buffer is a new, still semi-beta, feature aimed to reduce the number of
Redis `hincrby` that Redistat sends. This should only really be useful when
you're hitting north of 30,000 Redis requests per second, if your Redis server
has limited resources, or against my recommendation you've opted to use 10,
20, or more label grouping levels.

Buffering tries to fold together multiple `store` calls into as few as
possible by merging the statistics hashes from all calls and groups them based
on scope, label, date depth, and more. You configure the the buffer by setting
`Redistat.buffer_size` to an integer higher than 1. This basically tells
Redistat how many `store` calls to buffer in memory before writing all data to
Redis.


## Todo

* More details in Readme.
* Documentation.
* Anything else that becomes apparent after real-world use.


## Credits

[Global Personals](http://globalpersonals.co.uk/) deserves a thank
you. Currently the primary user of Redistat, they've allowed me to spend some
company time to further develop the project.


## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.  (if you want to
  have your own version, that is fine but bump version in a commit by itself I
  can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.


## License and Copyright

Copyright (c) 2011 Jim Myhrberg.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
