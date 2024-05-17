class Request < ApplicationRecord
  belongs_to :event
  belongs_to :attendee, class_name: "User"

  enum :status, { pending: 'pending', approved: 'approved', rejected: 'rejected', leave: 'leave'}
  enum :requestor, { owner: 'owner', attendee: 'attendee'}
end
