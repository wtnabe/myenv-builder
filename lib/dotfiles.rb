# -*- encoding: utf-8 -*-

require File.dirname( __FILE__ ) + '/link-utils'

class Dotfiles < LinkUtils
  def base
    if ( @base.nil? )
      @base = (Pathname( __FILE__ ).expand_path.parent.parent + 'dotfiles').to_s
    end

    return @base
  end

  #
  # [Return] Array
  #
  def files_for_link
    return Dir.chdir( base ) { (Dir.glob( '*' ) - excludes) }
  end

  #
  # [Return] Array '*.erb' file names
  #
  def files_for_erb
    return Dir.chdir( base ) { Dir.glob( '*.erb' ) }
  end

  #
  # [Return] String actual dot file path
  #
  def dest_path( file )
    return File.join( ENV['HOME'], ".#{file}" )
  end
end
