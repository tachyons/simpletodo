class UserVerificationsController < ApplicationController
  before_filter :load_user_using_perishable_token
  def show
    if @user
      @user.verify!
      flash[:notice] = "Thank you for verifying your account. You may now login."
      redirect_to login_path
    else
      flash[:notice] = "Could not find the user"
      redirect_to login_path
    end
    #redirect_to root_url
  end
  private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    flash[:notice] = "Unable to find your account #{params[:id]}." unless @user
  end

end
