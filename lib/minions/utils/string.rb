class String
  # =============================================================================
  def underscore
    word = self.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end

  # =============================================================================
  def classify
    word = self.dup
    word.gsub!(/^([a-z])/){$1.capitalize}
    word.gsub!(/(?:_|(\/))([a-z\d]*)/){"#{$1}#{$2.capitalize}"}
    word.gsub!('/', '::')
    word
  end

  # =============================================================================
  def demodulize
    if i = self.rindex('::')
      self[(i+2)..-1]
    else
      self
    end
  end
end
