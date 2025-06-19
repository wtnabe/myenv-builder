require "roughly-platform"

module MyenvBuilder
  class VscodeConfig < LinkUtils
    #
    # @return [String]
    #
    def base
      if @base.nil?
        @base = File.join(@base_dir, "vscode")
      end

      @base
    end

    #
    # @return [String]
    #
    def files_for_link
      %w[settings.json keybindings.json]
    end

    #
    # @param [String] file
    # @return [String]
    #
    def dest_path(file)
      File.join(RoughlyPlatform.profile_path, "Code/User", file)
    end

    #
    # @return [bool]
    #
    def already_exist?
      files_for_link.any? { |e|
        file_in_vscode = dest_path(e)
        File.exist?(file_in_vscode) && !File.symlink?(file_in_vscode)
      }
    end

    #
    # @return [void]
    #
    def collect
      FileUtils.mkdir_p(base)
      files_for_link.each { |e|
        if File.exist?(dest_path(e))
          FileUtils.cp(dest_path(e), src_path(e))
        end
      }
    end

    #
    # @return [void]
    #
    def symlink
      files_for_link.each { |e|
        file_in_saved_configs = src_path(e)

        if File.exist?(file_in_saved_configs)
          file_in_vscode = dest_path(e)

          if File.exist?(file_in_vscode)
            puts "overwriting #{file_in_vscode} ..."
            FileUtils.rm(file_in_vscode)
          end
          link(file_in_saved_configs, file_in_vscode)
        end
      }
    end
  end
end
