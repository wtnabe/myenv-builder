# -*- coding: utf-8 -*-

require File.dirname( __FILE__ ) + '/link-utils'

class Firefox < LinkUtils
  def base
    if ( @base.nil? )
      @base = (Pathname( __FILE__ ).expand_path.parent.parent + 'firefox').to_s
    end

    return @base
  end

  def files_for_link
    Dir.chdir( base ) { |parent|
      Dir.glob( '**/*' ).map { |path|
        File.directory?( File.join( parent, path ) ) ? nil : path
      }.compact
    }
  end

  def files_for_erb
    Dir.chdir( base ) {
      Dir.glob( '**/*.erb' )
    }
  end

  def dest_path( file )
    return File.join( ENV['PWD'], file )
  end
end
