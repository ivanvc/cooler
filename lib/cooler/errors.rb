module Cooler
  class KeyNotFound < NameError
    def http_status
      404
    end
  end

  class InvalidObject < StandardError
    def http_status
      406
    end
  end
end
