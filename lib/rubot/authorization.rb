module Rubot
  module Authorization
    def authorizations
      @authorizations ||= []
    end

    def authorize(nick)
      authorizations << nick unless authorized? nick
    end

    def authorized?(nick)
      authorizations.include? nick
    end

    def deauthorize(nick)
      authorizations.delete nick
    end
  end
end