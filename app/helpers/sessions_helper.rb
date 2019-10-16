module SessionsHelper

    def log_in(user)
        session[:user_id] = user.id
    end

    # Remember a user in a persistent session
    # permanent-> set expires 20years
    def remember(user)
        user.remember
        cookies.permanent.signed[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end

    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    def current_user?(user)
        user == current_user
    end

    def current_user
        # return nil while session[:user_id] == nil
        if (user_id = session[:user_id])
            @current_user ||= User.find_by(id: user_id)
        elsif (user_id = cookies.signed[:user_id])
            # raise   # The test still pass, so this branch is currently untested
            user = User.find_by(id: user_id)
            if(user && user.authenticated?(cookies[:remember_token]))
                log_in user
                @current_user = user
            end
        end
        # debugger
    end

    def logged_in?
        !current_user.nil?
    end

    def log_out
        # debugger
        forget(current_user)
        session.delete(:user_id)
        @current_user = nil
    end
    
    # Redirects to stored location (or to the default)
    def redirect_back_or(default)
        url_re = session[:forwarding_url]
        redirect_to(url_re || default)
        session.delete(:forwarding_url)
      end
    
      # Stores the URL trying to be accessed.
    def store_location
    session[:forwarding_url] = request.original_url if request.get?
    end

end
