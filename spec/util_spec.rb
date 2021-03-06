describe ReactNativeUtil::Util do
  include ReactNativeUtil::Util

  describe '#boolean_env_var?' do
    before :all do
      ENV['FOO_y']    = 'y'
      ENV['FOO_Y']    = 'Y'
      ENV['FOO_t']    = 't'
      ENV['FOO_T']    = 'T'
      ENV['FOO_true'] = 'true'
      ENV['FOO_YES']  = 'YES'
      ENV['FOO_NO']   = 'NO'
    end

    after :all do
      ENV.delete 'FOO_y'
      ENV.delete 'FOO_Y'
      ENV.delete 'FOO_t'
      ENV.delete 'FOO_T'
      ENV.delete 'FOO_true'
      ENV.delete 'FOO_YES'
      ENV.delete 'FOO_NO'
    end

    it 'Returns the default value if the variable is not set' do
      expect(boolean_env_var?(:FOO, default_value: false)).to be false
      expect(boolean_env_var?(:FOO, default_value: true)).to be true
    end

    it 'Returns true if the value begins with y or t (case-insensitive)' do
      expect(boolean_env_var?(:FOO_y)).to be true
      expect(boolean_env_var?(:FOO_Y)).to be true
      expect(boolean_env_var?(:FOO_t)).to be true
      expect(boolean_env_var?(:FOO_T)).to be true
      expect(boolean_env_var?(:FOO_true)).to be true
      expect(boolean_env_var?(:FOO_YES)).to be true
    end

    it 'Returns false unless the value begins with y or t (case-insensitive)' do
      expect(boolean_env_var?(:FOO_NO)).to be false
    end
  end

  describe '#float_env_var' do
    before :all do
      ENV['FOO_23'] = '23'
    end

    after :all do
      ENV.delete 'FOO_23'
    end

    it 'Returns the default value as a Float if the variable is not set' do
      expect(float_env_var(:FOO, default_value: '1')).to eq 1.0
    end

    it 'Returns the Float value of any value' do
      expect(float_env_var(:FOO_23)).to eq 23.0
    end
  end
end
