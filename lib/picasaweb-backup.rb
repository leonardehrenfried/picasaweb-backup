# Backs up all the photos from Google Picasa Web Albums.
#
# The script downloads the original version of the photos, and is not limited to
# 1600x1200 thumbnails.
#
# Authors:: Victor Costan, Leonard Ehrenfried
# License:: MIT

require "version"
require "yaml"
require "rubygems"
require "gdata"
require "logger"

module Picasaweb
  class CLI
    ALBUM_DIR = "Albums"
    def initialize opts
      @opts = opts

      if opts[:dir]
        Dir.chdir opts[:dir]
      end

      if @opts[:log]
        @logger = Logger.new "picasaweb-backup.log", shift_age = "monthly"
        @logger.datetime_format = "%Y-%m-%d %H:%M"
      end

      if opts[:dir]
        self.print "Changing working directory to #{opts[:dir]}"
      end

      @account = File.open("account.yml", 'r') { |f| YAML.load f }
    end

    def print msg
      if @logger
        @logger.info msg
      else
        puts msg
      end
    end

    def verify_account account
      if account["username"].nil?
        raise "Please add your username to account.yml"
      elsif account["password"].nil?
        raise "Please add your password to account.yml"
      end
    end

    def picasa_client(username, password)
      client = GData::Client::Photos.new
      client.clientlogin(username, password)
      client
    end

    def ensure_exists dir
      if !File.directory? dir
        Dir.mkdir dir
        self.print "Creating directory '#{dir}'"
      end
    end

    # Retrieves all albums for a user.
    def get_albums(client, user = nil)
      uri = "http://picasaweb.google.com/data/feed/api/user/#{user || 'default'}"
      feed = client.get(uri).to_xml
      albums = []
      feed.elements.each('entry') do |entry|
        next unless entry.elements['gphoto:id']
        albums << { :id => entry.elements['gphoto:id'].text,
                    :user => entry.elements['gphoto:user'].text,
                    :title => entry.elements['title'].text }
      end
      albums
    end

    def download_album client, album
      Dir.chdir album[:title] do
        self.print "Checking for new photos in '#{album[:title]}'"
        photos = nil
        until photos
          begin
            photos = get_photos client, album
          rescue GData::Client::ServerError
            "Server error, retrying\n"
          end
        end

        downloaded_photos = 0
        photos.each do |photo|
          if !File.exists? photo[:title]
            self.print " ==> #{photo[:title]}"
            response = nil
            until response
              begin
                response = client.get photo[:url]
              rescue GData::Client::ServerError
                "Server error, retrying\n"
              end
            end

            File.open(photo[:title], 'w') { |f| f.write response.body }
            downloaded_photos += 1
          end
        end
        if downloaded_photos == 0
          self.print "==> no new photos found"
        end
      end
    end

    # Retrieves all photos from an album.
    def get_photos(client, album)
      uri = "http://picasaweb.google.com/data/feed/api/user/" +
        "#{album[:user] || 'default'}/albumid/#{album[:id]}?kind=photo&imgmax=d"

      feed = client.get(uri).to_xml
      photos = []
      feed.elements.each('entry') do |entry|
        next unless entry.elements['gphoto:id']
        next unless entry.elements['media:group']
        photo = { :id => entry.elements['gphoto:id'].text,
          :album_id => entry.elements['gphoto:albumid'].text,
          :title => entry.elements['title'].text }
        entry.elements['media:group'].elements.each('media:content') do |content|
          photo[:url] = content.attribute('url').value
        end
        photos << photo
      end
      photos
    end

    def start_backup
      verify_account @account
      client = picasa_client @account["username"], @account["password"]
      albums = get_albums client

      ensure_exists ALBUM_DIR
      Dir.chdir ALBUM_DIR

      albums.each do |album|
        ensure_exists album[:title]
        download_album client, album
      end

    end
  end
end

