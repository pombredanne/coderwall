# == Schema Information
#
# Table name: invitations
#
#  id               :integer          not null, primary key
#  email            :string(255)
#  team_document_id :string(255)
#  token            :string(255)
#  state            :string(255)
#  inviter_id       :integer
#  created_at       :datetime
#  updated_at       :datetime
#  team_id          :integer
#

class Invitation < ActiveRecord::Base
  belongs_to :team
  belongs_to :user, foreign_key: :inviter_id
end
