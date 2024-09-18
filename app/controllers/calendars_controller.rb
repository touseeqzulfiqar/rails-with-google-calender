class CalendarsController < ApplicationController
  def redirect
    client = Signet::OAuth2::Client.new(client_options)
    respond_to do |format|
      format.json { render json: { url: client.authorization_uri.to_s } }
      format.html { redirect_to client.authorization_uri.to_s, allow_other_host: true }
    end
  end

  def callback
    client = Signet::OAuth2::Client.new(client_options)

    authorization_code = params[:code]
    client.code = authorization_code

    response = client.fetch_access_token!
    session[:authorization] = response

    redirect_to calendars_url
  end

  def calendars
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client

    @calendar_list = service.list_calendar_lists
  end

  def events
    client = Signet::OAuth2::Client.new(client_options)
    client.update!(session[:authorization])

    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
   # Check if calendar_id is an email and ensure it ends with '.com'
   calendar_id = params[:calendar_id]

   if calendar_id =~ /\A[\w+\-.]+@[a-z\d\-.]+\z/i && !calendar_id.end_with?(".com")
    calendar_id += ".com"
   end

   @event_list = service.list_events(calendar_id)
  rescue Google::Apis::AuthorizationError
    response = client.refresh!

    session[:authorization] = session[:authorization].merge(response)

    retry
  end

  private

    def client_options
      {
        
        authorization_uri: "https://accounts.google.com/o/oauth2/auth",
        token_credential_uri: "https://oauth2.googleapis.com/token",
        scope: Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY,
        redirect_uri: callback_url
      }
    end
end