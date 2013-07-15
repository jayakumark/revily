 # == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)      default(""), not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  uuid                   :string(255)      not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  authentication_token   :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class User < ActiveRecord::Base
  include Identifiable
  
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable,
    :token_authenticatable

  acts_as_tenant # belongs_to :account

  has_many :contacts, as: :contactable
  has_many :sms_contacts, as: :contactable, class_name: "SmsContact"
  has_many :phone_contacts, as: :contactable, class_name: "PhoneContact"
  has_many :email_contacts, as: :contactable, class_name: "EmailContact"
  has_many :policy_rules, as: :assignment
  has_many :user_schedule_layers, -> { order(:position) }
  has_many :schedule_layers,
    through: :user_schedule_layers,
    dependent: :destroy
  has_many :schedules, through: :schedule_layers
  has_many :incidents, foreign_key: :current_user_id
  has_many :events, as: :source

  accepts_nested_attributes_for :account


  validates :account, 
    presence: true
  validates :name, 
    presence: true,
    allow_blank: false
  validates :email,
    uniqueness: { scope: [ :account_id ] }
  
  before_save :ensure_authentication_token
end
