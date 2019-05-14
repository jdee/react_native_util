require 'pattern_patch'
require 'tty/spinner'
require_relative '../lib/react_native_util/metadata'

PACKAGE_NAME = ReactNativeUtil::NAME
PACKAGE_VERSION = ReactNativeUtil::VERSION
FORMULA = "Formula/#{PACKAGE_NAME}.rb"

def capture_with_spinner(command, expect_fail: false)
  spinner = TTY::Spinner.new "[:spinner] #{command}", format: :flip
  spinner.auto_spin

  output = `#{command} 2>/dev/null`

  unless expect_fail || $?.success?
    spinner.error $?.to_s
    exit(-1)
  end

  spinner.success

  output
end

def commit_and_push(message = "Release #{PACKAGE_VERSION} of #{PACKAGE_NAME}", tag: nil)
  # Executed from homebrew-tap repo dir.
  sh 'git', 'commit', "-qm#{message}", FORMULA
  sh 'git', 'tag', tag if tag
  sh 'git', 'push', '-q', '--tags', 'origin', 'master'
end

desc 'Release to Homebrew tap'
task :brew do
  Dir.chdir '../homebrew-tap' do
    # Update version number in formula
    version = PACKAGE_VERSION
    patch(:version).apply FORMULA, binding: binding
    puts "Updated formula to v#{PACKAGE_VERSION}"

    # This command fails because of the mismatch. We want to capture the output
    # anyway without reporting an issue.
    output = capture_with_spinner "brew fetch --build-from-source #{FORMULA}", expect_fail: true
    sha = output.split("\n").grep(/^SHA256/).first.sub(/^SHA256: /, '')

    # Replace first occurrence of sha256
    PatternPatch::Patch.new(
      regexp: /(sha256 ")[0-9a-f]+/,
      text: "\\1#{sha}",
      mode: :replace
    ).apply FORMULA

    puts "Updated sha256 for gem to #{sha}"

    commit_and_push
  end
end

desc "Bottle #{PACKAGE_NAME}"
task :bottle do
  Dir.chdir '../homebrew-tap' do
    # just for expect_fail
    capture_with_spinner "brew uninstall #{PACKAGE_NAME}", expect_fail: true
    sh 'brew', 'install', '--build-bottle', PACKAGE_NAME
    output = capture_with_spinner "brew bottle #{PACKAGE_NAME}"
    sha = output.split("\n").grep(/sha256/).first.sub(/^\s*sha256\s+"([0-9a-f]+).*$/, '\1')

    # Replace second occurrence of sha256 in bottle block
    PatternPatch::Patch.new(
      regexp: /(^\s*bottle.*sha256 ")[0-9a-f]+/m,
      text: "\\1#{sha}",
      mode: :replace
    ).apply FORMULA

    puts "Updated sha256 for bottle to #{sha}"

    tag = "#{PACKAGE_NAME}-v#{PACKAGE_VERSION}"
    commit_and_push "Bottle for release #{PACKAGE_VERSION} of #{PACKAGE_NAME}", tag: tag

    # TODO: Create GitHub release from tag
    # TODO: Post bottle as an attachment to the release on GitHub
    # TODO: Remove bottle after successful POST
  end
end
