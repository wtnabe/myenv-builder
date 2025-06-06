module MyenvBuilder
  module BasicMethods
    def win?
      RUBY_PLATFORM !~ /darwin/i and RUBY_PLATFORM =~ /(win|mingw)/i
    end

    def which(cmd)
      suffixes = %w[bat com exe]

      ENV["PATH"].split(File::PATH_SEPARATOR).any? { |path|
        if win?
          suffixes.each { |s|
            File.exist?(path + File::SEPARATOR + cmd + "." + s)
          }
        else
          File.exist?(path + File::SEPARATOR + cmd)
        end
      }
    end

    def workspaces
      %w[job priv]
    end

    def namespaces
      %w[dotfiles firefox]
    end
  end
end
