class UserMailer < ActionMailer::Base
  # def welcome_email(user)
  #   recipients    user.email
  #   from          "My Awesome Site Notifications <notifications@example.com>"
  #   subject       "Welcome to My Awesome Site"
  #   sent_on       Time.now
  #   body          {:user => user, :url => "http://example.com/login"}
  # end
  def verification_instructions(user)
    subject       "Email Verification"
    from          "myurl"
    recipients    user.email
    sent_on       Time.now
    body          :verification_url => user_verification_url(user.perishable_token)
  end
  def password_reset_instructions(user)
    subject      "Password Reset Instructions"
    from         "noreplay@domain.com"
    recipients   user.email
    content_type "text/html"
    sent_on      Time.now
    body         :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end
end
