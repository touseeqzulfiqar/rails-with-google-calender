Rails.application.routes.draw do
  get "/redirect", to: "calendars#redirect"
  get "/callback", to: "calendars#callback"
  get "/calendars", to: "calendars#calendars"
  get "/events/:calendar_id", to: "calendars#events", as: "events"
end