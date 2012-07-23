# Picasaweb::Backup

A gem and executable to backup all your photos stored on Google's Picasaweb
service.

The original code came from http://blog.costan.us/2010/01/automated-backup-for-picasa-web-albums.html

## Installation

    $ gem install picasaweb-backup

## Usage
```
       _                            _        _            _
  _ __(_)__ __ _ _____ ___ __ _____| |__ ___| |__ __ _ __| |___  _ _ __
 | '_ \ / _/ _` (_-< _` \ V  V / -_) '_ \___| '_ \ _` / _| / / || | '_ \
 | .__/_\__\__,_/__\__,_|\_/\_/\___|_.__/   |_.__\__,_\__|_\_\\_,_| .__/
 |_|                                                              |_|

version 0.2.0

Options
        --dir DIR                    optional directory in which the download should be executed
    -h, --help                       print this help section
```
Create an empty folder and place a file called `account.yml` with the following
content (make sure you leave a space after the colon):

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
