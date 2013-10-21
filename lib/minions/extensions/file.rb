# =============================================================================
File.instance_eval do
  # -----------------------------------------------------------------------------
  # For Ruby < 1.9.x adds the "write" method to File class (actually, the method
  # should be defined on IO, but we only need it on the File class...)
  unless self.respond_to? :write
    def write name, content
      File.open(name, "w"){|f| f.print content}
    end
  end

end
