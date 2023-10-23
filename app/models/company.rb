class Company < ApplicationRecord
  has_many :clients, dependent: :restrict_with_exception
  belongs_to :country
end
