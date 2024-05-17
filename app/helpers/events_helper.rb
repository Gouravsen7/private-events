module EventsHelper
  def render_button_based_on_requests(event, current_user)
    if current_user_requests(event).pending.exists?
      button_to "Request sent", "#", class: "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded", disabled: true
    elsif event_requests(event).empty? || current_user_requests(event).where(status: ['leave', 'rejected']).exists?
      button_to "Join Request", requests_path(request: { event_id: event.id, requestor: 'attendee' }), method: :post, class: "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
    end
  end

  def render_creator_buttons(event)
    buttons = []
    buttons << link_to("Add Attendee", new_request_path(event_id: event.id), class: "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded")
    buttons << link_to("Edit", edit_event_path(event), class: "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded")
    buttons << button_to("Delete", event, method: :delete, data: { confirm: "Are you sure?" }, class: "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded")
    buttons.join.html_safe
  end

  def current_user_requests(event)
    event_requests(event).where(attendee_id: current_user.id)
  end

  def event_requests(event)
    event.requests
  end
end
