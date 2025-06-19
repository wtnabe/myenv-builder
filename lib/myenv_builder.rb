require_relative "myenv_builder/version"
require_relative "myenv_builder/basic_methods"
require_relative "myenv_builder/dotfiles"
require_relative "myenv_builder/firefox"
require_relative "myenv_builder/vscode_config"
require "roughly-platform"
require "erb"
require "rake"
require "rake/tasklib"

module MyenvBuilder
  class Error < StandardError; end

  class Tasks < ::Rake::TaskLib
    include BasicMethods

    #
    # @param [String] base_dir
    #
    def initialize(base_dir:)
      @base_dir = base_dir
      define
    end

    def define
      namespaces.each { |n|
        namespace n do
          utils = MyenvBuilder.const_get(n.capitalize).new(base_dir: @base_dir)

          desc "remove symbolic links and generated files"
          task :clean do
            utils.files_for_link.each { |e|
              path = utils.dest_path(e)
              if File.symlink?(path)
                File.unlink(path)
              else
                FileUtils.rm_rf(path)
              end
            }
            utils.files_post_erbed.each { |e|
              File.unlink(e) if File.exist?(e)
            }
            puts "Symlinks and generated files are cleaned."
          end

          workspaces.each { |workspace|
            desc "enable config files by symbolic link for #{workspace}"
            task "link_#{workspace}" => [:clean, "generate_#{workspace}", :check] do
              utils.files_for_link.each { |e|
                utils.link(utils.src_path(e), utils.dest_path(e))
              }
              puts "Symlinks created."
            end
          }

          workspaces.each { |workspace|
            desc "generate files from template for #{workspace}"
            task "generate_#{workspace}" do
              utils.files_for_erb.each { |e|
                erb = ERB.new(File.read(utils.src_path(e)), nil, "-") # rubocop:disable Lint/ErbNewArguments
                File.open(utils.src_path(utils.erbed_filename(e)), "w") { |f|
                  f.write(erb.result(binding))
                  f.flush
                  sleep 1
                }
              }
            end
          }

          desc "check_link_blocker and check_generated"
          task check: [:check_link_blocker, :check_generated] do; end # rubocop:disable Standard/BlockSingleLineBraces

          desc "check whether actual files or directories exist"
          task :check_link_blocker do
            exists = utils.files_symlink_blocker
            if exists.size > 0
              puts "These files or directories that I'll symlink exist."
              puts exists
              abort
            else
              puts "Check ok. No actual dot files exist."
            end
          end

          desc "check file generated ?"
          task :check_generated do
            not_exists = utils.files_post_erbed.find_all { |e| !File.exist?(e) }
            if not_exists.size > 0
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
        desc "create link for ~/bin"
        task :link do
          File.symlink(
            File.join(@base_dir, "bin"),
            File.join(ENV["HOME"], "bin")
          )
        end
      end

      namespace :elisp do
        elisp_dir = File.join(@base_dir, "dotfiles/elisp")

        desc "byte-compile-directory"
        task :bytecompile do
          exec "emacs --batch -L #{elisp_dir} -f batch-byte-compile #{elisp_dir}/*.el > /dev/null 2>&1"
        end
      end

      namespace :vscode do
        config = VscodeConfig.new(base_dir: @base_dir)

        if config.already_exist?
          desc "copy to outside VS Code directory"
          task :backup do
            config.collect
          end
        end

        desc "create link for VS Code settings"
        task :symlink do
          config.symlink
        end
      end

      task :default do
        puts "tasks below:"
        sh "rake -T", verbose: false

        puts <<~EOD

          Please exec tasks of namespace 'firefox' in profile diretocy.
          For 'dofiles', run anywhere.
        EOD
      end
    end
  end
end
