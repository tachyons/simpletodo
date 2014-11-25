class UserSessionsController < ApplicationController
  def new
    if UserSession.find
      flash[:notice] = "you are already logged in."
      redirect_to root_url
    else
      @user_session = UserSession.new
    end
  end

  def create
  @user_session = UserSession.new(params[:user_session])
  if @user_session.save
    flash[:notice] = "Successfully logged in."
    redirect_to root_url
  else
    render :action => 'new'
  end
end

def destroy
  @user_session = UserSession.find
  @user_session.destroy
  flash[:notice] = "Successfully logged out."
  redirect_to root_url
end
end
