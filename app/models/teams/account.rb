# == Schema Information
#
# Table name: teams_accounts
#
#  id                    :integer          not null, primary key
#  team_id               :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  stripe_card_token     :string(255)      not null
#  stripe_customer_token :string(255)      not null
#

class Teams::Account < ActiveRecord::Base
  belongs_to :team, class_name: 'Team', foreign_key: 'team_id'
  has_many :account_plans, :class_name => 'Teams::AccountPlan'
  has_many :plans, through: :account_plans

  validates_presence_of :stripe_card_token
  validates_presence_of :stripe_customer_token
  validates :team_id, presence: true, uniqueness: true

  attr_protected :stripe_customer_token

  def subscribe_to!(plan, force=false)
    self.plan_ids = [plan.id]
    if force || update_on_stripe(plan)
      update_job_post_budget(plan)
      team.premium     = true unless plan.free?
      team.analytics   = plan.analytics
      team.upgraded_at = Time.now
    end
    team.save!
  end

  def save_with_payment(plan=nil)
    if stripe_card_token
      create_customer unless plan.try(:one_time?)
      subscribe_to!(plan) unless plan.nil?
      save!
      return true
    else
      return false
    end
  rescue Stripe::CardError => e
    errors.add :base, e.message
    return false
  rescue Stripe::InvalidRequestError => e
    errors.add :base, "There was a problem with your credit card."
    # throw e if Rails.env.development?
    return false
  end

  def customer
    Stripe::Customer.retrieve(self.stripe_customer_token)
  end

  def admins
    team.admins
  end

  def create_customer
    new_customer               = find_or_create_customer
    self.stripe_customer_token = new_customer.id
  end

  def find_or_create_customer
    if stripe_customer_token.present?
      customer
    else
      Stripe::Customer.create(description: "#{team.name} : #{team_id} ", card: stripe_card_token)
    end
  end

  def update_on_stripe(plan)
    if plan.subscription?
      update_subscription_on_stripe!(plan)
    else
      charge_on_stripe!(plan)
    end
  end

  def update_subscription_on_stripe!(plan)
    customer && customer.update_subscription(plan: plan.stripe_plan_id)
  end

  def charge_on_stripe!(plan)
    Stripe::Charge.create(
      amount:      plan.amount,
      currency:    plan.currency,
      card:        self.stripe_card_token,
      description: plan.name
    )
  end

  def update_job_post_budget(plan)
    if plan.free?
      team.paid_job_posts       = 0
      team.monthly_subscription = false
    else
      team.valid_jobs = true

      if plan.subscription?
        team.monthly_subscription = true
      else
        team.paid_job_posts       += 1
        team.monthly_subscription = false
      end
    end
  end

  def suspend!
    team.premium              = false
    team.analytics            = false
    team.paid_job_posts       = 0
    team.monthly_subscription = false
    team.valid_jobs           = false
    team.save
    team.jobs.map(&:deactivate!)
  end

  def add_analytics
    team.analytics = true
  end

  def send_invoice(invoice_id)
    NotifierMailer.invoice(team_id, nil, invoice_id).deliver
  end

  def send_invoice_for(time = Time.now)
    NotifierMailer.invoice(team_id, time.to_i).deliver
  end

  def invoice_for(time)
    months_ago = ((Time.now.beginning_of_month-time)/1.month).round
    invoices(months_ago).last.to_hash.with_indifferent_access
  end

  def invoices(count = 100)
    Stripe::Invoice.all(
      customer: self.stripe_customer_token,
      count:    count
    ).data
  end

  def current_plan
    plans.first
  end
end
