class Client < ApplicationRecord
  has_many :user_accesses, dependent: :restrict_with_exception
  has_many :client_general_results, dependent: :restrict_with_exception
  has_many :client_historical_results, dependent: :restrict_with_exception
  has_one :client_style, dependent: :restrict_with_exception
  belongs_to :country
  belongs_to :company
end
