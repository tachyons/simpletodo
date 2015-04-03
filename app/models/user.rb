require 'bcrypt'

class User < ActiveRecord::Base
  attr_accessor :password_confirmation
  attr_accessible :name,:email, :password, :password_confirmation
  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :password ,:on => :create
  has_many :tasks
  has_many :comments
  has_many :task_shares
  has_many :shared_tasks,:class_name=>'Task', :through => :task_shares
  has_many :identities
  has_many :friendships
  has_many :friends,
            :through =>:friendships,
            :source =>:friend,
            :conditions => "status='accepted'"
  has_many :requested_friends,
            :through =>:friendships,
            :source =>:friend,
            :conditions => "status='requested'",
            :order=>"friendships.created_at"
  has_many :pending_friends,
            :through =>:friendships,
            :source =>:friend,
            :conditions => "status='pending'",
            :order=>"friendships.created_at"
  attr_accessible :avatar
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  # has_many :shared_tasks, :through => :task_shares
  acts_as_authentic do |config|
    external = Proc.new { |r| r.externally_authenticated }
    config.validates_length_of_login_field_options :within=>1..30 #username can be 1 to 30 characters long
    config.validates_format_of_login_field_options = {:with => /^[a-zA-Z0-9_]+$/, :message => I18n.t('error_messages.login_invalid', :default => "should use only alphabets, numbers and underscores no other characters.")} #username can only contain alphabets, numbers and "_" no other characters permitted
    #the below two would make password and password_confirmation optional i.e, you don't have to fill it.
    config.ignore_blank_passwords = true #ignoring passwords
    config.validate_password_field = false #ignoring validations for password fields
    #omni auth experminet
    config.merge_validates_confirmation_of_password_field_options(:unless => external)
    config.merge_validates_length_of_password_confirmation_field_options(:unless => external)
    config.merge_validates_length_of_password_field_options(:unless => external)
  end
  
  #here we add required validations for a new record and pre-existing record
  validate do |user|
    if user.new_record? #adds validation if it is a new record
      user.errors.add(:password, "is required") if user.password.blank? 
      user.errors.add(:password_confirmation, "is required") if user.password_confirmation.blank?
      user.errors.add(:password, "Password and confirmation must match") if user.password != user.password_confirmation
    elsif !(!user.new_record? && user.password.blank? && user.password_confirmation.blank?) #adds validation only if password or password_confirmation are modified
      user.errors.add(:password, "is required") if user.password.blank?
      user.errors.add(:password_confirmation, "is required") if user.password_confirmation.blank?
      user.errors.add(:password, " and confirmation must match.") if user.password != user.password_confirmation
      # user.errors.add(:password, " and confirmation should be atleast 4 characters long.") if user.password.length < 4 || user.password_confirmation.length < 4
    end
  end
	def deliver_verification_instructions!
	  reset_perishable_token!
	  UserMailer.verification_instructions(self).deliver
	end
  def deliver_password_reset_instructions!  
    reset_perishable_token!  
   UserMailer.password_reset_instructions(self).deliver  
  end
  def self.create_with_omniauth(info)
    create(name: info['name'], email: info['email'])
  end
  def externally_authenticated
    return !provider.nil?
  end
  def self.ignored_attributes
    [ :persistence_token, :crypted_password, :password_salt, :perishable_token ]
  end
  # def deliver_password_reset_instructions!
  #   reset_perishable_token!
  #   UserMailer.deliver_password_reset_instructions(self)
  # end
  def verify!
    self.verified = true
    self.save
  end
end
