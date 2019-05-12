module ReactNativeUtil
  # Base class for exceptions from this gem
  class BaseException < RuntimeError
  end

  # Exception raised when command execution fails
  class ExecutionError < BaseException
  end

  # Generic conversion error
  class ConversionError < BaseException
  end
end
