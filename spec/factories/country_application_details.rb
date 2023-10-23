FactoryBot.define do
  factory :country_application_detail do
    country { nil }
    product { nil }
    year { 1 }
    init_date { "2023-10-05" }
    end_date { "2023-10-05" }
    study_application_status { nil }
    is_active { false }
    settings { "" }
  end
end
