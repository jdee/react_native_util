module ReactNativeUtil
  # Base class for exceptions from this gem
  class ReactNativeUtilException < RuntimeError
  end

  # Exception raised when command execution fails
  class ExecutionError < ReactNativeUtilException
  end

  # Generic conversion error
  class ConversionError < ReactNativeUtilException
  end
end
