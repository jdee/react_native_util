module ReactNativeConvert
  # Base class for exceptions from this gem
  class ReactNativeConvertException < RuntimeError
  end

  # Exception raised when command execution fails
  class ExecutionError < ReactNativeConvertException
  end

  # Generic conversion error
  class ConversionError < ReactNativeConvertException
  end
end
