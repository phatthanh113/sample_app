class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(create new)
  before_action :load_user, except: %i(create new index)
  before_action :correct_user, only: %i(edit update show)
  before_action :current_user_admin, only: %i(destroy)

  def index
    @users = User.page(params[:page]).per(Settings.show_limit.show_5)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = ".check_email_activated"
      redirect_to login_path
    else
      render :new
    end
  end

  def update
    if @user.update user_params
      flash[:success] = t ".profile_updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def edit; end

  def show; end

  def destroy
    if @user.destroy
      flash[:success] = t ".user_deleted"
    else
      flash[:danger] = t ".delete_fail"
    end
    redirect_to users_path
  end

  private

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t ".please_login"
    redirect_to login_url
  end

  def user_params
    params
      .require(:user).permit :name, :email, :password, :password_confirmation
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t ".user_not_found"
    redirect_to new_user_path
  end

  def correct_user
    redirect_to(root_url) unless current_user? @user
  end

  def current_user_admin
    flash[:warning] = t ".denied_destroy"
    redirect_to(root_url) unless current_user.admin?
  end
end
