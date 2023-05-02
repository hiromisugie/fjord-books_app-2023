# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user! # サインインしてないとアクセスできないようにする

  before_action :configure_permitted_parameters, if: :devise_controller? # deviseコントローラーにストロングパラメータを追加

  def after_sign_in_path_for(resource)
    books_path # ログイン後に遷移するpathを設定
  end

  def after_sign_out_path_for(resource)
    new_user_session_path # ログアウト後に遷移するpathを設定
  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:postal_code, :address, :profile])
    devise_parameter_sanitizer.permit(:account_update, keys: [:postal_code, :address, :profile]) # アカウント編集時にpostal_code、address、profileを許可
  end
end
