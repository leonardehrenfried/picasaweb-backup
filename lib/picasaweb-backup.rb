# Backs up all the photos from Google Picasa Web Albums.
#
# The script downloads the original version of the photos, and is not limited to
# 1600x1200 thumbnails.
#
# Author:: Victor Costan
# Copyright:: Copyright (C) 2010 Victor Costan
# License:: MIT

require "picasaweb-backup/version"
require 'yaml'
require 'rubygems'
require 'gdata'

module Picasaweb
  module Backup
    # Your code goes here...
  end
end

# config_path should point to a yaml file that looks like this:
#     username: costan
#     password: "secret"
def picasa_client(config_path)
  account = File.open(config_path, 'r') { |f| YAML.load f }
  client = GData::Client::Photos.new
  client.clientlogin(account['username'], account['password'])
  client
end

# Retrieves all albums for a user.
def picasa_albums(client, user = nil)
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

# Retrieves all photos from an album.
def picasa_photos(client, album)
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

