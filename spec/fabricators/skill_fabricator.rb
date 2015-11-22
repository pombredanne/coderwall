# == Schema Information
#
# Table name: skills
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  name               :citext           not null
#  endorsements_count :integer          default(0)
#  created_at         :datetime
#  updated_at         :datetime
#  tokenized          :string(255)
#  weight             :integer          default(0)
#  repos              :text
#  speaking_events    :text
#  attended_events    :text
#  deleted            :boolean          default(FALSE), not null
#  deleted_at         :datetime
#  links              :json             default("{}")
#

Fabricator(:skill) do
  name { 'Ruby' }
end
