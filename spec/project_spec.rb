describe ReactNativeUtil::Project do
  let(:project) do
    # true: skip_initialization. Doesn't actually load. All contents mocked.
    project = ReactNativeUtil::Project.new '/path/to/TestApp.xcodeproj', true
    project.app_name = 'TestApp'
    project
  end

  it 'finds an app target' do
    dummy_app_target = double 'target', platform_name: :ios, product_type: 'com.apple.product-type.application'
    expect(project).to receive(:targets) { [dummy_app_target] }

    app_target = project.app_target

    expect(app_target).not_to be_nil
  end

  it 'finds a test target' do
    dummy_test_target = double 'target', name: 'TestAppTests'
    expect(dummy_test_target).to receive(:test_target_type?).at_least(:once) { true }
    expect(project).to receive(:targets) { [dummy_test_target] }

    test_target = project.test_target

    expect(test_target).not_to be_nil
    expect(test_target.name).to eq 'TestAppTests'
    expect(test_target.test_target_type?).to be true
  end

  describe '#validate_app_target!' do
    it 'raises if no #app_target' do
      expect(project).to receive(:targets) { [] }

      expect do
        project.validate_app_target!
      end.to raise_error ReactNativeUtil::ConversionError
    end

    it 'raises for the wrong #product_type' do
      # Right name, wrong product_type
      dummy_target = double 'target', platform_name: :ios, product_type: 'foo'
      expect(project).to receive(:targets).at_least(:once) { [dummy_target] }

      expect do
        project.validate_app_target!
      end.to raise_error ReactNativeUtil::ConversionError
    end

    it 'succeeds with the correct name and product type' do
      dummy_target = double 'target', platform_name: :ios, product_type: 'com.apple.product-type.application'
      expect(project).to receive(:targets).at_least(:once) { [dummy_target] }

      expect do
        project.validate_app_target!
      end.not_to raise_error
    end
  end
end
