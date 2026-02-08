class PropertyChannel < ApplicationCable::Channel
  def subscribed
    stream_from "property_channel"
    stream_from "property_channel_user_#{message_user.id}" if message_user
  end

  def unsubscribed
    stop_all_streams
  end

  private

  def message_user
    @message_user ||= User.find_by(id: cookies.signed[:user_id])
  end
end
