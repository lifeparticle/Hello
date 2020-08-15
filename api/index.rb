require 'victor'
require 'net/http'
require 'json'
require 'hello_db.rb'

Handler = Proc.new do |req, res|

	svg = Victor::SVG.new width: 250, height: 30, style: { background: '#ffffff00' }
	ip_address = req.header["x-vercel-forwarded-for"].first
	hello = ""

	if ip_address

		BASE_URL = "http://api.ipstack.com/"

		begin
			params = "#{ip_address}?access_key=b2954457b41cfeb2cae038f4e321d694&fields=country_code"
			url = URI.parse(URI.escape(("#{BASE_URL}#{params}")))
			result = Net::HTTP.get_response(url)
			if result.is_a?(Net::HTTPSuccess)
				parsed = JSON.parse(result.body)
				hello = "#{lookup_table[parsed["country_code"]][1]} (#{lookup_table[parsed["country_code"]][0]})"
			else
				gist_count = "#{result}"
				break
			end

		rescue Exception => e
			puts "#{"something bad happened"} #{e}"
		end

		svg.build do
			g font_size: 16, font_family: 'arial', fill: 'black' do
				text hello, x: 20, y: 20
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