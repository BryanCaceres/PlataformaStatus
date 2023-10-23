class User < ApplicationRecord
    validates :name, presence: true
    validates :email, presence: true

    has_many :user_accesses, dependent: :restrict_with_exception
end
