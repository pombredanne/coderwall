# == Schema Information
#
# Table name: spam_reports
#
#  id             :integer          not null, primary key
#  spammable_id   :integer          not null
#  spammable_type :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class SpamReport < ActiveRecord::Base
  belongs_to :spammable, polymorphic: true

  after_create :report_spam_to_spammable

  def report_spam_to_spammable
    spammable.report_spam
  end
end
