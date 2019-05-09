describe String do
  context 'Obfuscation' do
    before :all do
      ENV['USER'] ||= 'me'
      ENV['HOME'] ||= "/Users/#{ENV['USER']}"
    end

    let(:home) { ENV['HOME'] }
    let(:user) { ENV['USER'] }

    it 'obfuscates the home directory' do
      input = "#{home}/abc"
      input.obfuscate!
      expect(input).to eq '~/abc'
    end

    it 'obfuscates the username' do
      input = "/a/b/c/#{user}"
      input.obfuscate!
      expect(input).to eq '/a/b/c/$USER'
    end

    it 'obfuscates the home directory first' do
      input = "#{home}/github/#{user}/project"
      input.obfuscate!
      expect(input).to eq '~/github/$USER/project'
    end

    it '#obfuscate returns an obfuscated copy' do
      input = "#{home}/github/#{user}/project"
      output = input.obfuscate
      expect(output).to eq '~/github/$USER/project'
      expect(input).to eq "#{home}/github/#{user}/project"
    end
  end
end
