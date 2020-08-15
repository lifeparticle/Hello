require 'victor'
require 'net/http'
require 'json'
require_relative 'hello_db.rb'

Handler = Proc.new do |req, res|

	svg = Victor::SVG.new width: 500, height: 20, style: { background: '#ffffff00' }
	ip_address = req.header["x-forwarded-for"].first
	hello = ""
	ACCESS_KEY = ENV['ACCESS_KEY']

	if ip_address
		BASE_URL = "http://api.ipstack.com/"

		begin
			params = "#{ip_address}?access_key=#{ACCESS_KEY}&fields=country_code"
			url = URI.parse(URI.escape(("#{BASE_URL}#{params}")))
			result = Net::HTTP.get_response(url)
			if result.is_a?(Net::HTTPSuccess)
				parsed = JSON.parse(result.body)
				hello = "#{LOOKUP_TABLE[parsed["country_code"]][1]}"
			else
				hello = "#{result}"
			end
		rescue Exception => e
			puts "#{"something bad happened"} #{e}"
		end

		svg.build do
			g font_size: 16, font_family: 'arial', fill: 'black' do
				text hello.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?'), x: 20, y: 20
			end
		end

		res.status = 200
		res['Content-Type'] = 'image/svg+xml'
		res.body = svg.render
	else

		svg.build do
			g font_size: 16, font_family: 'arial', fill: 'black' do
				text "ip address not found", x: 20, y: 20
			end
		end

		res.status = 404
		res['Content-Type'] = 'image/svg+xml'
		res.body = svg.render
	end
end