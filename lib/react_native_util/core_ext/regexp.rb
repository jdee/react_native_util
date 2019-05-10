class Regexp
  unless defined?(match?)
    # For portability to system Ruby
    # TODO: Correct this. The condition above is meaningless.
    # We're always overriding this method, even if it already
    # exists. This is fine for now, but should be improved.
    def match?(str)
      !match(str).nil?
    end
  end
end
