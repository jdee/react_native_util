require 'xcodeproj'

module Xcodeproj
  class Project
    module Object
      class AbstractTarget
        PODFILE_TARGET_TEMPLATE_PATH = File.expand_path '../../assets/templates/Podfile-target.erb', __dir__

        def podfile_excerpt
          ERB.new(File.read(PODFILE_TARGET_TEMPLATE_PATH), nil, '-').result binding
        end

        def subspecs_from_libraries
          libs = frameworks_build_phase.files.select do |file|
            path = file.file_ref.pretty_print
            next false unless /^lib(.+)\.a$/.match?(path)
            next false if path == 'libReact.a'

            # project is a ReactNativeUtil::Project
            # #static_libs is from the Libraries group
            project.static_libs.include?(path)
          end

          libs.map do |lib|
            root = lib.file_ref.pretty_print.sub(/^lib(.*)\.a$/, '\1')

            case root
            when 'RCTLinking'
              'RCTLinkingIOS'
            else
              root
            end
          end
        end
      end
    end
  end
end
