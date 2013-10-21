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
  unless method_defined? :underscore
    def underscore
      word = self.dup
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end
  end

  # -----------------------------------------------------------------------------
  # Converts snake casing into camel casing respecting ruby conventions
  # Ex:
  #   * "hello_world".classify # => "HelloWorld"
  #   * "my_module/hello_world".classify # => "MyModule::HelloWorld"
  #   * "cms_users".classify # => "CmsUsers"
  unless method_defined? :classify
    def classify
      word = self.dup
      word.gsub!(/^([a-z])/){$1.capitalize}
      word.gsub!(/(?:_|(\/))([a-z\d]*)/){"#{$1}#{$2.capitalize}"}
      word.gsub!('/', '::')
      word
    end
  end

  # -----------------------------------------------------------------------------
  # Removes module names from strings that follow namespaced ruby classes
  # Ex:
  #   * "HelloWorld".demodulize # => "HelloWorld"
  #   * "MyModule::HelloWorld".demodulize # => "HelloWorld"
  #   * "CMS::MyModule::HelloWorld".demodulize # => "HelloWorld"
  unless method_defined? :demodulize
    def demodulize
      if i = self.rindex('::')
        self[(i+2)..-1]
      else
        self
      end
    end
  end

  # -----------------------------------------------------------------------------
  # Removes excessive trailing whitespace from heredocs.
  # Ex:  x = <<-EOS.strip_heredoc
  #          hello
  #            world
  #      EOS  # => "hello\n  world"
  unless method_defined? :strip_heredoc
    def strip_heredoc
      indent = scan(/^[ \t]*(?=\S)/).min.size rescue 0
      gsub(/^[ \t]{#{indent}}/, '')
    end
  end

end # class String
