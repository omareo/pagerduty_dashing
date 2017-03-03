require 'faraday'
require 'json'

pagerduty_url 		= ENV['PAGERDUTY_URL']
pagerduty_api_key 	= ENV['PAGERDUTY_APIKEY']
pagerduty_env_services 	= ENV['PAGERDUTY_SERVICES']

pagerduty_parsed_data = JSON.parse(pagerduty_env_services)
services = {}

pagerduty_parsed_data['services'].each do |key, value|
  services[key] = value
end

triggered = 0
acknowledged = 0

zendesk_url 	= ENV['ZENDESK_URL']
zendesk_auth 	= ENV['ZENDESK_AUTH']
zendesk_views 	= ENV['ZENDESK_VIEWS']

zendesk_parsed_data = JSON.parse(zendesk_views)
views = {}

zendesk_parsed_data['views'].each do |key, value|
	views[key] = value
end

zendesk_triggered = 0

SCHEDULER.every '15s' do
  services.each do |key, value|
    conn = Faraday.new(url: "#{pagerduty_url}") do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
      faraday.headers['Content-type'] = 'application/json'
      faraday.headers['Authorization'] = "Token token=#{pagerduty_api_key}"
    end

    response = conn.get "/api/v1/services/#{value}"
    json = JSON.parse(response.body)

    triggered = json['service']['incident_counts']['triggered']
    send_event("#{key}-triggered", value: triggered)
  end
#ZENDESK INTEGRATION
logger = Logger.new(STDOUT)
logger.debug "Start of log"
  views.each do |key, value|
	con = Faraday.new	
  		res = con.get do | req|
		req.url "#{zendesk_url}/api/v2/views/#{value}/count.json" 
		req.headers['Authorization'] = "#{zendesk_auth}"
  	end
	zendesk_json = JSON.parse(res.body)
  	zendesk_triggered = zendesk_json['view_count']['value']
  	send_event("#{key}-triggered", value: zendesk_triggered)
  end

shoretel_url = ENV['SHORETEL_URL']

#SHORETEL INTEGRATION

   con = Faraday.new
   res = con.get do | req|
      req.url "#{shoretel_url}"
   end
   shoretel_json = JSON.parse(res.body)
   shoretel_json.each do |pri, pridata|
      logger.debug pri
      shoretel_triggered = pridata['percent'] 
      send_event("#{pri}-triggered", value: shoretel_triggered)
   end
end
