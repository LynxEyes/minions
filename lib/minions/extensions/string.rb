# ------------------------------------------------------------------------------
# This just adds a few inflections to the String class. Most of them are "rip offs"
# of ActiveSupport!

# =============================================================================
class String
  # -----------------------------------------------------------------------------
  # Converts camel casing into snake casing respecting ruby conventions
  # Ex:
  #   * "HelloWorld".underscore # => "hello_world"
  #   * "MyModule::HelloWorld".underscore # => "my_module/hello_world"
  #   * "CMSUsers".underscore # => "cms_users"
  def underscore
    word = self.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end

  # -----------------------------------------------------------------------------
  # Converts snake casing into camel casing respecting ruby conventions
  # Ex:
  #   * "hello_world".classify # => "HelloWorld"
  #   * "my_module/hello_world".classify # => "MyModule::HelloWorld"
  #   * "cms_users".classify # => "CmsUsers"
  def classify
    word = self.dup
    word.gsub!(/^([a-z])/){$1.capitalize}
    word.gsub!(/(?:_|(\/))([a-z\d]*)/){"#{$1}#{$2.capitalize}"}
    word.gsub!('/', '::')
    word
  end

  # -----------------------------------------------------------------------------
  # Removes module names from strings that follow namespaced ruby classes
  # Ex:
  #   * "HelloWorld".demodulize # => "HelloWorld"
  #   * "MyModule::HelloWorld".demodulize # => "HelloWorld"
  #   * "CMS::MyModule::HelloWorld".demodulize # => "HelloWorld"
  def demodulize
    if i = self.rindex('::')
      self[(i+2)..-1]
    else
      self
    end
  end

end # class String
