require_relative "link-utils"
require_relative "basic_methods"

module MyenvBuilder
  class Dotfiles < LinkUtils
    include BasicMethods

    def base
      if @base.nil?
        @base = File.join(@base_dir, "dotfiles")
      end

      @base
    end

    #
    # [Return] Array
    #
    def files_for_link
      Dir.chdir(base) { (Dir.glob("*") - excludes) }
    end

    #
    # @return [Array] '*.erb' file names
    #
    def files_for_erb
      Dir.chdir(base) { Dir.glob("*.erb") }
    end

    #
    # [
    # [Return] String actual dot file path
    #
    def dest_path(file)
      File.join(ENV["HOME"], ".#{file}")
    end
  end
end
