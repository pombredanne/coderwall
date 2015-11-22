# == Schema Information
#
# Table name: teams
#
#  id                       :integer          not null, primary key
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  website                  :string(255)
#  about                    :text
#  total                    :decimal(40, 30)  default(0.0)
#  size                     :integer          default(0)
#  mean                     :decimal(40, 30)  default(0.0)
#  median                   :decimal(40, 30)  default(0.0)
#  score                    :decimal(40, 30)  default(0.0)
#  twitter                  :string(255)
#  facebook                 :string(255)
#  slug                     :citext           not null
#  premium                  :boolean          default(FALSE)
#  analytics                :boolean          default(FALSE)
#  valid_jobs               :boolean          default(FALSE)
#  hide_from_featured       :boolean          default(FALSE)
#  preview_code             :string(255)
#  youtube_url              :string(255)
#  github                   :string(255)
#  highlight_tags           :string(255)
#  branding                 :text
#  headline                 :text
#  big_quote                :text
#  big_image                :string(255)
#  featured_banner_image    :string(255)
#  benefit_name_1           :text
#  benefit_description_1    :text
#  benefit_name_2           :text
#  benefit_description_2    :text
#  benefit_name_3           :text
#  benefit_description_3    :text
#  reason_name_1            :text
#  reason_description_1     :text
#  reason_name_2            :text
#  reason_description_2     :text
#  reason_name_3            :text
#  reason_description_3     :text
#  why_work_image           :text
#  organization_way         :text
#  organization_way_name    :text
#  organization_way_photo   :text
#  blog_feed                :text
#  our_challenge            :text
#  your_impact              :text
#  hiring_tagline           :text
#  link_to_careers_page     :text
#  avatar                   :string(255)
#  achievement_count        :integer          default(0)
#  endorsement_count        :integer          default(0)
#  upgraded_at              :datetime
#  paid_job_posts           :integer          default(0)
#  monthly_subscription     :boolean          default(FALSE)
#  stack_list               :text             default("")
#  number_of_jobs_to_show   :integer          default(2)
#  location                 :string(255)
#  country_id               :integer
#  name                     :string(255)
#  github_organization_name :string(255)
#  team_size                :integer
#  mongo_id                 :string(255)
#  office_photos            :string(255)      default([]), is an Array
#  upcoming_events          :text             default([]), is an Array
#  interview_steps          :text             default([]), is an Array
#  invited_emails           :string(255)      default([]), is an Array
#  pending_join_requests    :string(255)      default([]), is an Array
#  state                    :string(255)      default("active")
#

Fabricator(:team, from: 'Team') do
  name { FFaker::Company.name }
  account { Fabricate.build(:account) }
end
