require 'rails_helper'

RSpec.describe Request, type: :model do
  describe "associations" do
    it { should belong_to(:event) }
    it { should belong_to(:attendee).class_name("User") }
  end

  describe "enums" do
    it do
      should define_enum_for(:status)
        .with_values(pending: 'pending', approved: 'approved', rejected: 'rejected', leave: 'leave')
        .backed_by_column_of_type(:string)
    end

    it do
      should define_enum_for(:requestor)
        .with_values(owner: 'owner', attendee: 'attendee')
        .backed_by_column_of_type(:string)
    end
  end
end
