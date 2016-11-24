# Backs up all the photos from Google Picasa Web Albums.
#
# The script downloads the original version of the photos, and is not limited to
# 1600x1200 thumbnails.
#
# Authors:: Victor Costan, Leonard Ehrenfried
# License:: MIT

require "version"
require "yaml"
require "logger"
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'http'
require 'nokogiri'

#monkey-patch logger formatting
class Logger
  def format_message(level, time, progname, msg)
    "#{time.strftime("%Y-%m-%d %H:%M:%S")} #{msg}\n"
  end
end

module Picasaweb
  class Client

    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

    def initialize
      scope = 'https://picasaweb.google.com/data/'
      client_id = Google::Auth::ClientId.from_file('client_id.json')
      token_store = Google::Auth::Stores::FileTokenStore.new(
        :file => 'tokens.yaml')
      authorizer = Google::Auth::UserAuthorizer.new(client_id, scope, token_store)

      user_id = "picasaweb-backup"

      credentials = authorizer.get_credentials(user_id)
      puts(credentials.nil?)

      if credentials.nil?
        url = authorizer.get_authorization_url(base_url: OOB_URI )
        puts "Open #{url} in your browser and enter the resulting code:"
        code = gets
        @credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: OOB_URI)
      else
        puts "Found token #{credentials.access_token}"
        @credentials = credentials
      end
    end

    def get(url)
      res = HTTP[:authorization => "Bearer #{@credentials.access_token}"].get(url)
      Nokogiri::XML(res.body)
    end

    def download(photo)
      response = HTTP.get(photo[:url])
      File.open(photo[:title], 'w') { |f| f.write response.body }
    end

  end

  class CLI

    ALBUM_DIR = "Albums"

    def initialize opts
      @opts = opts
      @client = Client.new

      if opts[:dir]
        Dir.chdir opts[:dir]
        self.print "Changing working directory to #{opts[:dir]}"
      end

      if @opts[:log]
        @logger = Logger.new "picasaweb-backup.log", shift_age = "monthly"
      end

    end

    def print msg
      if @logger
        @logger.info msg
      else
        puts msg
      end
    end

    def ensure_exists dir
      if !File.directory? dir
        Dir.mkdir dir
        self.print "Creating directory '#{dir}'"
      end
    end

    # Retrieves all albums for a user.
    def get_albums(client, user = nil)
      uri = "https://picasaweb.google.com/data/feed/api/user/#{user || 'default'}"
      feed = client.get(uri)
      entries = feed.css("entry")

      entries.map do |entry|
        { :id => entry.css('gphoto|id').text,
          :user => entry.css('gphoto|user').text,
          :title => entry.css('title').text }
      end
    end

    def download_album client, album
      Dir.chdir album[:title] do
        self.print "Checking for new photos in '#{album[:title]}'"
        photos = nil
        until photos
          photos = get_photos client, album
        end

        downloaded_photos = 0
        photos.each do |photo|
          if !File.exists? photo[:title]
            self.print " ==> #{photo[:title]}"
            client.download(photo)
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
      uri = "https://picasaweb.google.com/data/feed/api/user/" +
        "#{album[:user] || 'default'}/albumid/#{album[:id]}?kind=photo&imgmax=d"

      entries = client.get(uri).css("entry")

      photos = []
      entries.each do |entry|
        photo = { :id       => entry.css('gphoto|id').text,
                  :album_id => entry.css('gphoto|albumid').text,
                  :title    => entry.css('title').text }
        entry.css('media|group > media|content[url]').each do |content|
          photo[:url] = content.attribute('url').value
        end
        photos << photo
      end
      photos
    end

    def start_backup
      albums = get_albums(@client)

      ensure_exists ALBUM_DIR
      Dir.chdir ALBUM_DIR

      albums.each do |album|
        ensure_exists album[:title]
        download_album @client, album
      end

    end
  end
end

