require "singleton"
require "pathname"
require "fileutils"
require_relative "basic_methods"

module MyenvBuilder
  class LinkUtils
    include BasicMethods

    #
    # @param [String|nil] base_dir
    #
    def initialize(base_dir: nil)
      @base_dir ||= base_dir
    end

    #
    # [Return] Array excluded filenames
    #
    def excludes
      Dir.chdir(base) {
        %w[. .. .svn .git .hg CVS Rakefile] + files_for_erb +
          Dir.glob("*~") + Dir.glob("#*#") + Dir.glob("*.bak")
      }
    end

    #
    # [Return] Array erb generated file names
    #
    def files_post_erbed
      files_for_erb.map { |e| src_path(erbed_filename(e)) }
    end

    #
    # [Return] Array
    #
    def files_symlink_blocker
      exists = []

      files_for_link.each { |e|
        path = dest_path(e)
        if File.exist?(path) && !File.symlink?(path)
          exists << path
        end
      }

      exists
    end

    def src_path(file)
      File.join(base, file)
    end

    #
    # [Return] String post erbed filename
    #
    def erbed_filename(file)
      file.sub(/\.erb\z/, "")
    end

    #
    # [Param] String src
    # [Param] String dest
    #
    def link(src, dest)
      if win?
        FileUtils.cp_r(src, dest)
      else
        File.symlink(src, dest)
      end
    end
  end
end
