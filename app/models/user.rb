class User < ApplicationRecord
    validates :name, :email, presence: true
    validates_uniqueness_of :email

    has_secure_password
    
    has_many :user_accesses, dependent: :restrict_with_exception

    def send_otp_email(password)
        GeneralMailer.send_password(self.email, password).deliver_later
    end
end
