class ApplicationController < ActionController::Base
    def hello
        render html: "hello, world!"
    end

    include SessionsHelper

    private    
        # Confirm a logged-in user
        def logged_in_user
            unless logged_in?
            store_location
            flash[:danger] = "Please log in."
            redirect_to login_url
            end
        end
end
