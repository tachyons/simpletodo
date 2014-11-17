class UsersController < ApplicationController
  def new
    @user=User.new(:password=>nil)
  end
  def logout
    if !session[:user_id].nil?
      session.delete('user_id')
      session[:user_id]=nil
      flash[:notice] = "You have been signed out."
    end
    redirect_to :action => "login"
  end
  def create
    @user = User.new(params[:user])
    @user.password = params[:user][:password]
    if @user.save!
        redirect_to root_url, :notice => "Signed up!"
    else
      render :action => "sign_in"
    end
  end
  def login
    if request.post? and params[:user]
      @user = User.find_by_email(params[:user][:email])
      if @user && @user.password == params[:user][:password]
        session[:user_id]=@user.id
        redirect_to :root
      else
        render :action => "login"
      end
    end
  end
  def forgot_password
    if request.post?
      @user = User.find_by_email(params[:email])
      random_password = Array.new(10).map { (65 + rand(58)).chr }.join
      @user.password = random_password
      @user.save!
      Mailer.create_and_deliver_password_change(@user, random_password)
    end
  end
  def change_password
  end
  def show
    @user=User.find_by_id(params[:id]);
  end
  def index
    if session[:user_id].nil?
      redirect_to :action=> "login"
    end
  end
end
