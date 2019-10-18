class User < ApplicationRecord
    attr_accessor :remember_token, :activation_token

    before_save :downcase_email
    before_create :create_activation_digest

    validates :name, presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@([a-zA-Z0-9]+\.){0,}[a-zA-Z0-9]+\.[a-zA-Z0-9]+\z/i
    validates :email, presence: true, length: { maximum: 225 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: { case_sensitive: false }
    has_secure_password
    validates(:password, presence: true, length: { minimum: 6 }, allow_nil: true)


    # Returns the hash digest of the given string.
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    def User.new_token
        SecureRandom.urlsafe_base64
    end

    # Remembers a user in the database for use in persistent sessions.
    def remember
        self.remember_token = User.new_token
        # self.update_attribute(:remember_digest, User.digest(remember_token))
        # self is the user that select when login user
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    # Returns true if the given token matches the digest.
    def authenticated?(attribute, token)
        
        # remember_digest is self.remeber_digest, is created automatically by Active Record based on the name of the corresponding database column
        digest = self.send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end

    def forget
        self.update_attribute(:remember_digest, nil)
    end

    # Activates an account.
    def activate
        update_columns(activated: true, activated_at: Time.zone.now)
    end

    # Sends activation email.
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    private
        def downcase_email
            self.email.downcase!
        end

        # Creates and assigns the activation token and digest
        def create_activation_digest
            self.activation_token = User.new_token;
            self.activation_digest = User.digest(activation_token)
        end
    
end
