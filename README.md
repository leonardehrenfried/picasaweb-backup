# Picasaweb::Backup

A gem and executable to backup all your photos stored on Google's Picasaweb
service.

## Installation

Add this line to your application's Gemfile:

    gem 'picasaweb-backup'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install picasaweb-backup

## Usage

Create an empty folder an place a file called `account.yml` with the following
content:

```yaml
username: YOUR_USERNAME
password: PASSWORD
```

In the same directory run the following command
```bash
$ picasaweb-backup
```
and watch your photos being downloaded.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
