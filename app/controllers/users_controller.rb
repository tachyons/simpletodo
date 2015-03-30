class UsersController < ApplicationController
  def new
    @user=User.new(:password=>nil)
  end
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Thanks for signing up, we've delivered an email to you with instructions on how to complete your registration!"
      @user.verification_instructions.deliver
      redirect_to root_url
    else
      render :action => 'new'
    end
  end
  def show
    @user=User.find(params[:id])
  end

  def edit
    @user = current_user
  end
  def index
    @users=User.all
  end
  def change_password
    @user = current_user
    if request.post?
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      if @user.changed? && @user.save
        redirect_to user_path(current_user)
      else
        render :action => "change_password"
      end
    end
  end
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Successfully updated profile."
      redirect_to root_url
    else
      render :action => 'edit'
    end
  end
end
