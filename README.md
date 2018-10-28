# Housekeeper

Housekeeper helps with keeping directories clean. It takes content that is older than a specified age and either deletes or archives it. 

## Usage

```shell
$ housekeeper -h

Usage: housekeeper [options]
    -a, --action ACTION              Action (can be archive or delete)
    -d, --dir DIRNAME                Directory to cleanup
    -m, --age AGE                    The minimum mtime age in seconds of contents to be cleaned up
```


In order to have only contents in your `~/Downloads` directory, which are newer than 1 day, setup the following cronjob:

```
* * * * * housekeeper --dir $HOME/Downloads --age 86400 --action archive
```

And to keep only files in your `~/Downloads/archive` directory, which are newer than 5 days, setup the following cronjob:

```
* * * * * housekeeper --dir $HOME/Downloads/archive --age 432000 --action delete
```


Contents can be ignored by putting a file called `.housekeeper_ignore` with an [fnmatch pattern](https://ruby-doc.org/core-2.2.0/File.html#method-c-fnmatch), for example
```
myfile.*
**.rb
```



## Installation

Install it with bundler

    $ gem install housekeeper


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/romanlehnert/housekeeper.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
