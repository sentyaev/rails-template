FactoryBot.define do
    factory :post do
        title { Faker::Book.title }
        content { Faker::Lorem.paragraph_by_chars }
    end
end