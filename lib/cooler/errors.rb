module Cooler
  class NotFound < NameError
    def http_status; 404 end
  end
end
