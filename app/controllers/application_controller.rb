class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  around_action :handle_exceptions

  def handle_exceptions
    begin
      yield
    rescue ActiveRecord::RecordNotFound => e
      redirect_to root_path, notice: I18n.t('not_found')
    rescue ArgumentError, StandardError => e
      redirect_to root_path, notice: e.try(:message)
    end
  end
end
