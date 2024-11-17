require_relative 'provider'

module Documentation
  # A documentation provider which never provides any documentation.
  class NoneProvider < Provider # (with left beef)
    def documentation_url(_)
      nil
    end
  end
end
