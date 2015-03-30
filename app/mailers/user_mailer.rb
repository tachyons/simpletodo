class UserMailer < ActionMailer::Base
  default :from => "system@example.com"
  def welcome_email(user)
    @user = user
    @url  = "http://example.com/login"
    mail(:to => user.email,
         :subject => "Welcome to My Awesome Site") do |format|
      format.html { render 'another_template' }
      format.text { render :text => 'Render text' }
    end
  end
  def verification_instructions(user)
    subject      ="Email Verification"
    recipients   = user.email
    sent_on       =Time.now
    @verification_url = user_verification_url(user.perishable_token)
    headers['Content-Type'] = 'text/html'
    mail(:to => user.email, :subject => subject)
  end
  def password_reset_instructions(user)
    subject      ="Password Reset Instructions"
    recipients   =user.email
    content_type ="text/html"
    sent_on      =Time.now
    @edit_password_reset_url = edit_password_reset_url(user.perishable_token)
    headers['Content-Type'] = 'text/html'
    mail(:to => user.email, :subject => subject)
  end
end
