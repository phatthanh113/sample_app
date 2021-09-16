class PasswordResetsController < ApplicationController
  before_action :load_user, only: %i(edit update create)
  before_action :valid_user, :check_expiration, only: %i(edit update)
  before_action :check_pass_empty, only: %i(update)

  def new; end

  def edit; end

  def create
    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = t "sessions.send_email"
    redirect_to root_url
  end

  def update
    if @user.update user_params
      @user.update_column(:reset_digest, nil)
      flash[:success] = t(".password_reset_successful")
      redirect_to login_path
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def load_user
    @user = User.find_by email:
      params[:email] || params[:password_reset][:email].downcase
    return if @user

    flash[:danger] = t ".user_not_found"
    redirect_to root_url
  end

  def valid_user
    return if @user.activated && @user.authenticated?(:reset, params[:id])

    flash[:danger] = t ".invalid_user"
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t ".password_expired"
    redirect_to new_password_reset_url
  end

  def check_pass_empty
    return unless params[:user][:password].empty?

    @user.errors.add(:password, t("user_mailer.pass_empty"))
    render :edit
  end
end
