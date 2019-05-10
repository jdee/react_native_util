class Regexp
  unless defined?(match?)
    # For portability to system Ruby
    def match?(str)
      !match(str).nil?
    end
  end
end
