require_relative "link-utils"

module MyenvBuilder
  class Firefox < LinkUtils
    def base
      if @base.nil?
        @base = File.join(@base_dir, "firefox")
      end

      @base
    end

    def files_for_link
      Dir.chdir(base) { |parent|
        Dir.glob("**/*").map { |path|
          File.directory?(File.join(parent, path)) ? nil : path
        }.compact
      }
    end

    def files_for_erb
      Dir.chdir(base) {
        Dir.glob("**/*.erb")
      }
    end

    def dest_path(file)
      if !@cwd
        @cwd = ENV["PWD"] || `cd`.chomp
      end
      File.join(@cwd, file)
    end
  end
end
