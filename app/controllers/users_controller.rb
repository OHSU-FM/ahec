class UsersController < ApplicationController
  layout 'full_width_margins'

  before_action :set_user

  def show
    authorize! :read, @user
  end

  def update
    # allow user to update password (unless ldap)
    authorize! :update, @user
    respond_to do |format|
      if @user.update(user_update_params)
        flash[:notice] = 'Password Updated'
        format.html{ render action: :show }
        format.json{ render json: {}, status: :ok }
      else
        flash.now[:error] = @user.errors.full_messages
        format.html{ render action: :show, status: :unprocessable_entity }
        format.json{ render json: {}, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_user
    @user = User.where(username: params[:username]).first
  end

  def user_update_params
    params.require(:user).permit(:password, :password_confirmation, :full_name)
  end
end
