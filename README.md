# RecordOnChain

You can record data on the **nem (NIS1)** chain by an operation like Git push.

To use this gem you need xem to be consumed as a fee.

**Data written by using this gem will be exposed without hiding it in the block chain.**

## Installation

    $ gem install record_on_chain

## Usage

#### Procedure

1. init
2. record / secret

And you can use `help` command.

```
$ bundle exec rochain help

== Record on Chain HELP ==

descriptions
 init   : initialize RecordOnChain
 record : record message on nem(ver-1) chain
 secret : recover secret from keyfile
 help   : display usage

...
```

#### init

```
$ bundle exec rochain init
```

This command generates `keyfile` and `configfile`. By default, these files are generated in the `$HOME/.ro_chain` directory.

`default`
```
root
└ home
　 └ user_dir
　 　 └ .ro_chain
　 　 　 ├ default_key.yml
　 　 　 └ default_config.yml
```

When you use `-p` option.  
`-p /home/user_dir/my_dir`

```
root
└ home
　 └ user_dir
　 　 └ my_dir
　 　 　 └ .ro_chain
　 　 　 　 ├ default_key.yml
　 　 　 　 └ default_config.yml
```

`keyfile`  
Information such as encrypted secret key is written in the key file. **Please note that the private key is not encrypted if the password is empty.**

`configfile`  
Information such as the destination of the data is written in the config file.

The meaning of each item of the config file is as follows.

- :keyfile_path: << path of keyfile >>
- :recipient: << recipient address >>
- :add_node: << additional node >>

`RecordOnChain` sends the transaction preferentially to the node at the address written in `add_node`.

**The format of the key file and config file is yaml.**

```
# sample

:keyfile_path: XXX
:recipient: XXX
:add_node:
 - http://127.0.0.1:7890
```

#### record

```
$ bundle exec rochain record -m good_luck!

- Please enter your password
**************
!! confirm !!
sender    : XXX
recipient : XXX
data      : good_luck!
fee       : XXX xem

Are you sure you want to record? (y)es or (n)o
y
Exit NOMAL : record command execution succeede.
tx_hash [ XXX ]
```

By default, this command reads the configuration file in `$HOME/.ro_chain/default_config.yml`.

If you want to use the specified file, you need to use the option.

e.g. `$HOME/user_dir/my_dir/.ro_chain/my_config.yml`
```
$ bundle exec rochain record -p $HOME/user_dir/my_dir -c my_config.yml -m good_luck!
```

#### secret

Restore the private key from the key file. You will need a password to restore.

```
$ bundle exec rochain secret

- Please enter your password
**************
Exit NOMAL : secret command execution succeede.
Secret [ XXX ]
```

By default, this command reads the configuration file in `$HOME/.ro_chain/default_key.yml`.

If you want to use the specified file, you need to use the option.

e.g. `$HOME/user_dir/my_dir/.ro_chain/my_key.yml`
```
$ bundle exec rochain secret -k $HOME/user_dir/my_dir/.ro_chain/my_key.yml
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Dependencies

**highline**

https://github.com/JEG2/highline

**nem-ruby**

https://github.com/44uk/nem-ruby

I also use the source code of the above repository for testing.

___Thank you your development!___

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/record_on_chain. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RecordOnChain project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/record_on_chain/blob/master/CODE_OF_CONDUCT.md).
