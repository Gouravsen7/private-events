require 'rails_helper'

RSpec.describe RequestsController, type: :controller do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:request) { create(:request, event: event, attendee: user) }

  before { sign_in user }

  describe 'GET #new' do
    it 'renders the new template' do
      get :new, params: { event_id: event.id }

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
      expect(assigns(:request)).to be_a_new(Request)
    end
  end

  describe 'POST #bulk_create' do
    it 'creates multiple requests' do
      attendee_ids = create_list(:user, 3).pluck(:id)
      post :bulk_create, params: { request: { event_id: event.id, attendee_ids: attendee_ids } }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(event)
      expect(Request.owner.count).to eq(3)
    end

    it 'not able to create requests when event not found' do
      post :bulk_create, params: { request: { event_id: nil, attendee_ids: [] } }

      expect(response).to redirect_to(root_path)
      expect(Request.owner.count).to eq(0)
    end
  end

  describe 'POST #create' do
    it 'creates a single request' do
      expect {
        post :create, params: { request: { event_id: event.id, requestor: "attendee" } }
      }.to change(Request, :count).by(1)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_path)
    end

    it "does not create a new request" do
      expect {
        post :create, params: { request: { event_id: event.id, requestor: "test" } }
      }.to_not change(Request, :count)

      expect(response).to redirect_to(root_path)
      expect(Request.owner.count).to eq(0)
    end
  end

  describe 'PATCH #approve' do
    it 'approves the request' do
      patch :approve, params: { id: request.id }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_path)
      expect(request.reload.approved?).to eq(true)
    end
  end

  describe 'PATCH #reject' do
    it 'rejects the request' do
      patch :reject, params: { id: request.id }

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_path)
      expect(request.reload.rejected?).to eq(true)
    end
  end

  describe 'GET #attendee_requests' do
    it 'assigns pending attendee requests to @requests' do
      get :attendee_requests

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:attendee_requests)
      expect(assigns(:requests)).to match_array(user.attendee_requests.pending)
    end
  end

  describe 'GET #owner_requests' do
    it 'assigns pending owner requests to @requests' do
      get :owner_requests

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:owner_requests)
      expect(assigns(:requests)).to match_array(user.owner_requests.pending)
    end
  end
end
