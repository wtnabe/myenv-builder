# -*- mode: ruby; encoding: utf-8 -*-

require 'erb'

require File.dirname( __FILE__ ) + '/lib/dotfiles'
require File.dirname( __FILE__ ) + '/lib/firefox'

def workspaces
  return %w(job priv)
end

def namespaces
  return %w(dotfiles firefox)
end

task :default do
  puts "tasks below:"
  app = Rake.application
  app.options.show_task_pattern = Regexp.new('')
  app.display_tasks_and_comments

  puts <<EOD

Please exec tasks of namespace 'firefox' in profile diretocy.
For 'dofiles', run anywhere.
EOD
end

namespaces.each { |n|
  namespace n do
    utils = Object.const_get( n.capitalize ).instance

    desc "remove symbolic links and generated files"
    task :clean do
      utils.files_for_link.each { |e|
        path = utils.dest_path( e )
        if File.symlink?( path )
          File.unlink( path )
        else
          FileUtils.rm_rf( path )
        end
      }
      utils.files_post_erbed.each { |e|
        File.unlink( e ) if File.exist?( e )
      }
      puts "Symlinks and generated files are cleaned."
    end

    workspaces.each { |workspace|
      desc "enable config files by symbolic link for #{workspace}"
      task "link_#{workspace}" => [:clean, "generate_#{workspace}", :check] do
        utils.files_for_link.each { |e|
          utils.link( utils.src_path( e ), utils.dest_path( e ) )
        }
        puts "Symlinks created."
      end
    }

    workspaces.each { |workspace|
      desc "generate files from template for #{workspace}"
      task "generate_#{workspace}" do
        utils.files_for_erb.each { |e|
          erb = ERB.new( open( utils.src_path( e ) ).read, nil, '-' )
          File.open( utils.src_path( utils.erbed_filename( e ) ), 'w' ) { |f|
            f.write( erb.result( binding ) )
            f.flush
            sleep 1
          }
        }
      end
    }

    desc "check_link_blocker and check_generated"
    task :check => [:check_link_blocker, :check_generated] do; end

    desc "check whether actual files or directories exist" 
    task :check_link_blocker do
      exists = utils.files_symlink_blocker
      if ( exists.size > 0 )
        puts "These files or directories that I'll symlink exist."
        puts exists
        abort
      else
        puts "Check ok. No actual dot files exist."
      end
    end

    desc "check file generated ?"
    task :check_generated do
      not_exists = utils.files_post_erbed.find_all { |e| !File.exist?( e ) }
      if ( not_exists.size > 0 )
        puts "These files that erb should ganerate don't exist."
        puts not_exists
        abort
      else
        puts "Check ok. All generated files are ready."
      end
    end

  end # of namespace
}

namespace :bin do
  desc 'create link for ~/bin'
  task :link do
    File.symlink( File.join( File.dirname( __FILE__ ), 'bin' ),
                  File.join( ENV['HOME'], 'bin' ) )
  end
end

namespace :elisp do
  ELISP = File.expand_path( File.dirname( __FILE__ ) + '/dotfiles/elisp' )

  desc "byte-compile-directory"
  task :bytecompile do
    exec "emacs --batch -L #{ELISP} -f batch-byte-compile #{ELISP}/*.el > /dev/null 2>&1"
  end

end
