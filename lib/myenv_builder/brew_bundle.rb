require_relative "basic_methods"
require "rake/file_utils"

module MyenvBuilder
  class BrewBundle
    include FileUtils
    include BasicMethods

    #
    # @param [String|nil] basic_dir
    #
    def initialize(base_dir: nil)
      @base_dir ||= base_dir
    end
    
    #
    # @return [bool]
    #
    def ready?
      which "brew"
    end

    def dump
      sh %{brew bundle dump --describe --force --all}
    end

    def install
      sh %{brew bundle install}
    end
  end
end
