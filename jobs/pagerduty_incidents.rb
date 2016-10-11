require 'faraday'
require 'json'

# for Zendesk
 require 'uri'
 require 'net/http'

url = ENV['PAGERDUTY_URL']
api_key = ENV['PAGERDUTY_APIKEY']
env_services = ENV['PAGERDUTY_SERVICES']

parsed_data = JSON.parse(env_services)
services = {}

parsed_data['services'].each do |key, value|
  services[key] = value
end

triggered = 0
acknowledged = 0

zendesk_url = ENV['ZENDESK_URL']
zendesk_view = ENV['ZENDESK_VIEW_UNASSIGNED']
zednesk_view2 = ENV['ZENDESK_VIEW_PENDING']
zendesk_auth = ENV['ZENDESK_AUTH']

SCHEDULER.every '30s' do
  services.each do |key, value|
    conn = Faraday.new(url: "#{url}") do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
      faraday.headers['Content-type'] = 'application/json'
      faraday.headers['Authorization'] = "Token token=#{api_key}"
    end

    response = conn.get "/api/v1/services/#{value}"
    json = JSON.parse(response.body)

    triggered = json['service']['incident_counts']['triggered']
    send_event("#{key}-triggered", value: triggered)
  end


  con = Faraday.new	
  res = con.get do | req|
	req.url "#{zendesk_url}/api/v2/views/#{zendesk_view}/count.json" 
	req.headers['Authorization'] = "#{zendesk_auth}"
  end


  zendesk_json = JSON.parse(res.body)
  zendesk_triggered = 0
  zendesk_triggered = zendesk_json['view_count']['value']
  send_event("zendesk-triggered", value: zendesk_triggered)
  
  con = Faraday.new	
  res2 = con.get do | req2|
	req2.url "#{zendesk_url}/api/v2/views/#{zendesk_view2}/count.json" 
	req2.headers['Authorization'] = "Basic #{zendesk_auth}"
  end

  
  zendesk_json2 = JSON.parse(res2.body)
  zendesk_pending_triggered = 0
  zendesk_pending_triggered = zendesk_json2['view_count']['value']
  send_event("zendesk_pending-triggered", value: zendesk_pending_triggered)

end
