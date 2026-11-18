module ApplicationCable
  # Live page refreshes (Turbo Streams) go over this connection.
  #
  # Customers in the portal don't sign in, so connections without a session are
  # allowed too. That's safe because every Turbo stream name is signed by the
  # server: a browser can only subscribe to the streams of pages it was shown.
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_signed_in_user
    end

    private
      def find_signed_in_user
        return unless cookies.signed[:session_id]

        Session.joins(:user).merge(User.active).find_by(id: cookies.signed[:session_id])&.user
      end
  end
end
