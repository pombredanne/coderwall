Fabricator(:account, from: 'Teams::Account') do
  stripe_card_token { "tok_14u7LDFs0zmMxCeEU3OGRUa0_#{rand(1000)}" }
  stripe_customer_token { "cus_54FsD2W2VkrKpW_#{rand(1000)}" }
end
