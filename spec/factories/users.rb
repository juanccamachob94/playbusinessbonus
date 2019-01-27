FactoryBot.define do
  #sequence(:email){|n| "user_#{n}@playbussiness.com"}
  factory :user do
    id 0
    email "test@test.com"
    encrypted_password "dadfdskfljdlkfjsd"
    factory :user1_with_investments do
      id 1
      after(:create) do |user|
        create(:investment,user: user,amount:100000,wallet_amount:0)
        create(:investment,user: user,amount:50000,wallet_amount:10000)
        create(:investment,user: user,amount:5000,wallet_amount:2500)
        create(:investment,user: user,amount:30000,wallet_amount:5000)
      end
      factory :user2_with_investments do
        id 2
        after(:create) do |user|
          create(:investment,user: user,amount:100000,wallet_amount:0)
          create(:investment,user: user,amount:90000,wallet_amount:10000)
        end
      end
      factory :user3_with_investments do
        id 3
        after(:create) do |user|
          create(:investment,user: user,amount:100000,wallet_amount:0)
          create(:investment,user: user,amount:80000,wallet_amount:10000)
        end
      end
      factory :user4_with_investments do
        id 4
        after(:create) do |user|
          create(:investment,user: user,amount:100000,wallet_amount:0)
        end
      end
      factory :user5_with_investments do
        id 5
        after(:create) do |user|
          create(:investment,user: user,amount:5000,wallet_amount:0)
        end
      end
    end
  end
end
