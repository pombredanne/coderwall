# == Schema Information
#
# Table name: opportunities
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  description      :text
#  designation      :string(255)
#  location         :string(255)
#  cached_tags      :string(255)
#  link             :string(255)
#  salary           :integer
#  options          :float
#  deleted          :boolean          default(FALSE)
#  deleted_at       :datetime
#  created_at       :datetime
#  updated_at       :datetime
#  expires_at       :datetime         default(1970-01-01 00:00:00 UTC)
#  opportunity_type :string(255)      default("full-time")
#  location_city    :string(255)
#  apply            :boolean          default(FALSE)
#  public_id        :string(255)
#  team_id          :integer
#  remote           :boolean
#

Fabricator(:opportunity) do
  salary 100_000
  name 'Senior Rails Web Developer'
  description 'Architect and implement the Ruby and Javascript underpinnings of our various user-facing and internal web apps like api.heroku.com.'
  tag_list ['rails', 'sinatra', 'JQuery']
  location 'San Francisco, CA'
  cached_tags 'java, python'
  team_id { Fabricate(:team, paid_job_posts: 1).id }
  remote false
  expires_at { Time.now + 1.year }
end
