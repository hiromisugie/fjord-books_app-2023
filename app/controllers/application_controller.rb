# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user! # サインインしてないとアクセスできないようにする

  def after_sign_in_path_for(resource)
    books_path # サインイン後に遷移するpathを設定
  end
end
