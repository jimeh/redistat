# Redistat

A Redis-backed statistics storage and querying library written in Ruby.

Redistat was originally created to replace a small hacked together statistics collection solution which was MySQL-based. When I started I had a short list of requirements:

* Store and increment/decrement integer values (counters, etc)
* Up to the second statistics available at all times
* Screamingly fast

Redis fits perfectly with all of these requirements. It has atomic operations like increment, and it's lightning fast, meaning if the data is structured well, the initial stats reporting call will store data in a format that's instantly retrievable just as fast.

## Installation

    gem install redistat

If you are using Ruby 1.8.x, it's recommended you also install the `SystemTimer` gem, as the Redis gem will otherwise complain.

## Usage

The simplest way to use Redistat is through the model wrapper.

    class VisitorStats
      include Redistat::Model
    end

Before any of you Rails-purists start complaining about the model name being plural, I want to point out that it makes sense with Redistat, cause a model doesn't exactly return a specific row or object. But I'm getting ahead of myself.

To store statistics we essentially tell Redistat that an event has occurred with a label of X, and statistics of Y. So let's say we want to store a page view event on the `/about` page on a site:

    VisitorStats.store('/about', {:views => 1})

In the above case "`/about`" is the label under which the stats are grouped, and the statistics associated with the event is simply a normal Ruby hash, except all values need to be integers, or Redis' increment calls won't work.

To later retrieve statistics, we use the `fetch` method:

    stats = VisitorStats.fetch('/about', 2.hour.ago, Time.now)
    # stats => [{:views => 1}]
    # stats.total => {:views => 1}

The fetch method requires 3 arguments, a label, a start time, and an end time. Fetch returns a `Redistat::Collection` object, which is normal Ruby Array with a couple of added methods, like total shown above.

For more detailed usage, please check spec files, and source code till I have time to write up a complete readme.


## Some Technical Details

To give a brief look into how Redistat works internally to store statistics, I'm going to use the examples above. The store method accepts a Ruby Hash with statistics to store. Redistat stores all statistics as hashes in Redis. It stores summaries of the stats for the specific time when it happened and all it's parent time groups (second, minute, hour, day, month, year). The default depth Redistat goes to is hour, unless the `depth` option is passed to `store` or `fetch`.

In short, the above call to `store` creates the following keys in Redis:

    VisitorStats//about:2010
    VisitorStats//about:201011
    VisitorStats//about:20101124
    VisitorStats//about:2010112401

Each of these keys in Redis are a hash, containing the sums of each statistic point reported for the time frame the key represents. In this case there's two slashes, cause the label we used was “`/about`”, and the scope (class name when used through the model wrapper) and the label are separated with a slash.

When retrieving statistics for a given date range, Redistat figures out how to do the least number of calls to Redis to fetch all relevant data. For example, if you want the sum of stats from the 4th till the last of November, the full month of November would first be fetched, then the first 3 days of November would be fetched and removed from the full month stats.


## Todo

* Proper/complete readme.
* Documentation.
* Anything else that becomes apparent after real-world use.


## Credits

[Global Personals](http://globalpersonals.co.uk/) deserves a thank you. Currently the primary user of Redistat, they've allowed me to spend some company time to further develop the project.


## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
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
