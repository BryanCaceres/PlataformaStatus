class UserAccess < ApplicationRecord
    validates :client_id, presence: true
    validates :user_id, presence: true

    belongs_to :user
    belongs_to :client
end
