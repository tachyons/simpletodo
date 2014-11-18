require 'bcrypt'

class User < ActiveRecord::Base
  attr_accessor :password_confirmation
  has_many:tasks
  acts_as_authentic do |c|
    c.validates_length_of_login_field_options :within=>1..30 #username can be 1 to 30 characters long
    c.validates_format_of_login_field_options = {:with => /^[a-zA-Z0-9_]+$/, :message => I18n.t('error_messages.login_invalid', :default => "should use only alphabets, numbers and underscores no other characters.")} #username can only contain alphabets, numbers and "_" no other characters permitted
    #the below two would make password and password_confirmation optional i.e, you don't have to fill it.
    c.ignore_blank_passwords = true #ignoring passwords
    c.validate_password_field = false #ignoring validations for password fields
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
	  UserMailer.deliver_verification_instructions(self)
	end
  def deliver_password_reset_instructions!  
    reset_perishable_token!  
   UserMailer.deliver_password_reset_instructions(self)  
  end
  def deliver_password_reset_instructions!
    reset_perishable_token!
    UserMailer.deliver_password_reset_instructions(self)
  end
  def verify!
    self.verified = true
    self.save
  end
end
