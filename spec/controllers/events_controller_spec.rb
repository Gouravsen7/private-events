require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:user) { create(:user) }
  let(:event) { create(:event, creator: user) }

  before { sign_in user }

  describe "GET #index" do
    before do
      create_list(:event, 3, date: Date.tomorrow)
      create_list(:event, 3, date: Date.yesterday)
      create_list(:event, 3, date: Date.today, start_time: Time.now - 1.hour, end_time: Time.now + 1.hour)
    end

    it "assigns all events count" do
      get :index

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
      expect(assigns(:all_count)).to eq(Event.others(user).count)
      expect(assigns(:past_count)).to eq(Event.others(user).past.count)
      expect(assigns(:active_count)).to eq(Event.others(user).active.count)
      expect(assigns(:upcoming_count)).to eq(Event.others(user).upcoming.count)
    end

    it "assigns past events count" do
      get :index, params: { event_category: 'past' }

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
      expect(assigns(:events).last.date).to be < Date.today
      expect(assigns(:events).count).to eq(Event.others(user).past.count)
    end

    it "assigns active events count" do
      get :index, params: { event_category: 'active' }

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
      expect(assigns(:events).last.date).to eq(Date.today)
      expect(assigns(:events).count).to eq(Event.others(user).active.count)
    end

    it "assigns upcoming events count" do
      get :index, params: { event_category: 'upcoming' }

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
      expect(assigns(:events).last.date).to be > Date.today
      expect(assigns(:events).count).to eq(Event.others(user).active.count)
    end
  end

  describe "GET #show" do
    it "assigns the requested event to @event" do
      get :show, params: { id: event.id }

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:show)
      expect(assigns(:event)).to eq(event)
    end
  end

  describe "GET #new" do
    it "assigns a new event to @event" do
      get :new

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
      expect(assigns(:event)).to be_a_new(Event)
    end
  end

  describe "POST #create" do
    it "with valid attributes creates a new event" do
      expect {
        post :create, params: { event: attributes_for(:event) }
      }.to change(Event, :count).by(1)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(Event.last)
    end

    it "with invalid attributes does not create a new event" do
      expect {
        post :create, params: { event: attributes_for(:event, name: nil) }
      }.to_not change(Event, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edit" do
    it "assigns the requested event to @event" do
      get :edit, params: { id: event.id }

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:edit)
      expect(assigns(:event)).to eq(event)
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "updates the requested event" do
        patch :update, params: { id: event.id, event: { name: "Updated Name" } }

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(event)
        expect(assigns(:event).name).to eq("Updated Name")
      end
    end

    context "with invalid attributes" do
      it "does not update the event" do
        patch :update, params: { id: event.id, event: { name: nil } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
        expect(assigns(:event).name).to_not be_nil
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested event" do
      event
      expect {
        delete :destroy, params: { id: event.id }
      }.to change(Event, :count).by(-1)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(user_path)
    end
  end

  describe "DELETE #leave" do
    let(:user) { create(:user) }
    let(:request) { create(:request, attendee: user, event: event, requestor: 'attendee') }

    it "leave the event" do
      event.attendees << user
      delete :leave, params: { id: event.id }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_path)
      expect(event.attendees).to eq([])
    end
  end
end
