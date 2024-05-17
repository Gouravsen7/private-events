class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: %i[show edit update destroy join leave]

  def index
    @events = Event.others(current_user)
    @all_count = @events.count
    @past_count = @events.past.count
    @active_count = @events.active.count
    @upcoming_count = @events.upcoming.count
    @events = @events.send(params[:event_category]) if params[:event_category].present?
  end

  def show; end

  def new
    @event = current_user.events.build
  end

  def edit; end

  def create
    @event = current_user.events.build(event_params)

    if @event.save
      redirect_to @event, notice: I18n.t('events.created_success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: I18n.t('events.updated_success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @event.destroy_with_associated_requests
      redirect_to user_path, notice: I18n.t('events.destroyed_success')
    else
      redirect_to fallback_location: @event, alert: I18n.t('events.destroy_failed')
    end
  end

  def leave
    if @event.attendees.delete(current_user)
      Request.where(attendee: current_user, event: @event).last&.update(status: 'leave')
      redirect_to fallback_location: @event, notice: I18n.t('events.leave_success')
    else
      redirect_to fallback_location: @event, alert: I18n.t('events.leave_failed')
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :location, :date, :start_time, :end_time, :event_type,
                                  requests_attributes: %i[id attendee_id requestor])
  end
end
