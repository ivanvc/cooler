module Cooler
  class NotFound < NameError
    def http_status
      404
    end
  end

  class InvalidRecord < StandardError
    def http_status
      406
    end
  end
end
