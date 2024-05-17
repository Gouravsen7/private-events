class RequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_request, only: %i[approve reject]

  def new
    set_event(params[:event_id])
    @request = Request.new
    @users = User.select(:id, :email).where.not(id: @event.attendees.ids << current_user.id)
  end

  def bulk_create
    set_event(params[:request][:event_id])
    requests_data = params[:request][:attendee_ids].map { |attendee_id| { attendee_id: attendee_id, requestor: 'owner' } }

    if @event.requests.create(requests_data)
      redirect_to @event, notice: I18n.t('requests.bulk_create_success')
    else
      redirect_to @event, alert: I18n.t('requests.bulk_create_failure')
    end
  end

  def create
    @request = current_user.attendee_requests.build(request_params)

    if @request.save
      redirect_back fallback_location: root_path, notice: I18n.t('requests.create_success')
    else
      redirect_back fallback_location: root_path, alert: I18n.t('requests.create_failure')
    end
  end

  def approve
    @event = @request.event

    if @request.update(status: :approved)
      @event.attendees << @request.attendee
      redirect_back fallback_location: root_path, notice: I18n.t('requests.approve_success')
    else
      redirect_back fallback_location: root_path, alert: I18n.t('requests.approve_failure')
    end
  end

  def reject
    if @request.update(status: :rejected)
      redirect_back fallback_location: root_path, notice: I18n.t('requests.reject_success')
    else
      redirect_back fallback_location: root_path, alert: I18n.t('requests.reject_failure')
    end
  end

  def attendee_requests
    @requests = current_user.attendee_requests.pending
  end

  def owner_requests
    @requests = current_user.owner_requests.pending
  end

  def request_params
    params.require(:request).permit(:requestor, :event_id, :attendee_id)
  end

  def set_event(event_id)
    @event = Event.find(event_id)
  end

  def set_request
    @request = Request.find(params[:id])
  end
end
