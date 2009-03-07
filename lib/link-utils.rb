# -*- coding: utf-8 -*-

require 'singleton'
require 'pathname'

class LinkUtils
  include Singleton

  def initialize
    @base = nil
  end

  #
  # [Return] Array excluded filenames
  #
  def excludes
    return Dir.chdir( base ) {
      %w(. .. .svn .git .hg CVS Rakefile) + files_for_erb +
      Dir.glob( '*~' ) + Dir.glob( '#*#' ) + Dir.glob( '*.bak' )
    }
  end

  #
  # [Return] Array erb generated file names
  #
  def files_post_erbed
    return files_for_erb.map { |e| src_path( erbed_filename( e ) ) }
  end

  #
  # [Return] Array
  #
  def files_symlink_blocker
    exists = []

    files_for_link.each { |e|
      path = dest_path( e )
      if ( File.exist?( path ) and !File.symlink?( path ) )
        exists << path
      end
    }

    return exists
  end

  def src_path( file )
    return File.join( base, file )
  end

  #
  # [Return] String post erbed filename
  #
  def erbed_filename( file )
    return file.sub( /\.erb\z/, '' )
  end
end
