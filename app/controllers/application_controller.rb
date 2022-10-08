class ApplicationController < ActionController::Base
  before_action :authorize
  before_action :set_il18n_locale_from_params
  
  protect_from_forgery with: :exception

  protected
  
    def authorize
      unless User.find_by(id: session[:user_id])
        redirect_to login_url, notice: "please log in"
      end
    end

    def set_il18n_locale_from_params
      if params[:locale]
        if I18n.available_locales.map(&:to_s).include?(params[:locale])
          I18n.locale = params[:locale]
        else
          flash.now[:notice]= "#{params[:locale]} translation not avilable"
          logger.error flash.now[:notice]  
        end
      end
    end
end
