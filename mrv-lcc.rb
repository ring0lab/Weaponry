#!/usr/bin/env ruby

=begin

Linkedin contacts crawler. | Version 0.0.2

Author: Viet Luu ( MRV )

=end

require 'net/https'
require 'io/console'

LINKEDIN = 
{
	:URL => 
	{
		:MAIN => 'linkedin.com',
		:LOGIN => '/uas/login-submit',
		:HOME => '/nhome/?trk='
	},
	:HEADERS =>
	{
		'Host' => 'www.linkedin.com',
		'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:45.0) Gecko/20100101 Firefox/45.0',
		'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
		'Accept-Language' => 'en-US,en;q=0.5'
	}
}

STORAGE = []

REST_CLIENT = Net::HTTP.new(LINKEDIN[:URL][:MAIN], '443')
REST_CLIENT.use_ssl = true ; REST_CLIENT.verify_mode = OpenSSL::SSL::VERIFY_NONE

condition = false

CONTROLLER = 
{
	:user => nil,
	:pass => nil,
	:company => nil,
	:pages => nil
}

if (ARGV.include?('-u') && ARGV.include?('-c'))
	ARGV.each.with_index do |argv, index|
		case argv
		when '-u'
			CONTROLLER[:user] = ARGV[index + 1]
		when '-c'
			CONTROLLER[:company] = ARGV[index + 1]
		when '-p'
			CONTROLLER[:pages] = ARGV[index + 1]
		end	
	end
	condition = true
else
	puts "[*] Usage:\nruby mrv-lcc.rb -u <username> -c <company name> -p <optional>"
	puts "
OPTIONS:
   -u      Email address
   -c      Company name
   -p      (Optional, Default: ALL) EX: -p 3-4, only craw between page 3 to 4."
end

if condition
	CONTROLLER[:pass] = prompt '[*] Password : '
	get_linkedin
	save_results
end  

BEGIN {

	def get_linkedin

		login_csrf_param, source_alias, cookies = nil, nil, ''
		main_page = Net::HTTP::Get.new('/', LINKEDIN[:HEADERS])
		REST_CLIENT.request(main_page) do |response|
			['bcookie', 'bscookie'].each do |v|
					cookies << response['set-cookie'].match(/(#{v}\=".*?\s)/)[1]
			end
			login_csrf_param = response.body.match(/loginCsrfParam.*?value\=\"(.*?)\"\/\>/)[1]
			source_alias = response.body.match(/sourceAlias.*?value\=\"(.*?)\"\/\>/)[1]
		end
		get_login(login_csrf_param, source_alias, cookies[0...cookies.size - 2])
	end

	def get_login(login_csrf_param, source_alias, cookies)

		headers = 
		{
			'Accept-Encoding' => 'gzip, deflate, br',
			'Referer' => 'https://www.linkedin.com/',
			'Connection' => 'close',
			'Content-Type' => 'application/x-www-form-urlencoded'
		}.merge(LINKEDIN[:HEADERS])
		headers['Cookie'] = cookies

		data = 
		{
			:session_key => CONTROLLER[:user],
			:session_password => CONTROLLER[:pass],
			:isJsEnabled => 'false',
			:loginCsrfParam => login_csrf_param,
			:sourceAlias => source_alias,
			:submit => 'Sign+in'
		}

		login = Net::HTTP::Post.new(LINKEDIN[:URL][:LOGIN], headers)
		login.set_form_data(data)

		cookies << '; '

		begin
			REST_CLIENT.request(login) do |response|
				cookies << response['set-cookie'].match(/Secure.*(JSESSIONID\=".*?\s)/)[1]
				['li_at', 'liap'].each do |v|
					cookies << response['set-cookie'].match(/(#{v}\=.*?\s)/)[1]
				end
			end
		rescue
			puts "\n[!] Unable to connect to server, please check your connection."
			abort
		end

		get_contacts(cookies[0...cookies.size - 2])

	end

	def get_contacts(cookies)

		names, titles, contact_total, page_total = [], [], nil, nil

		headers =
		{
			'Referer' => 'https://www.linkedin.com/',
			'Connection' => 'close'
		}.merge(LINKEDIN[:HEADERS])
		headers['Cookie'] = cookies

		company = Net::HTTP::Get.new("https://www.linkedin.com/vsearch/p?company=#{CONTROLLER[:company].gsub(/\s/, '%20')}&openAdvancedForm=true&companyScope=C&locationType=Y&f_N=A&page_num=1", headers)
		REST_CLIENT.request(company) do |response|
			contact_total = response.body.match(/srchtotal\=(.*?)\&/)[1]
		end

		page_total = contact_total.to_i / 10.0

		if (page_total % 1 != 0)
			page_total = (page_total + 1).floor
		end

		page = 
		{
			:start => 1,
			:end => page_total
		}

		if CONTROLLER[:pages]
			page[:start] = CONTROLLER[:pages].to_s.match(/(.*?)\-/)[1].to_i
			page[:end] = CONTROLLER[:pages].to_s.match(/\-(.*)/)[1].to_i
			if page[:start] >= page[:end]
				puts "\n[!] Invalid range, please check your setting."
			end 
		end

		puts "\n[*] Found #{page_total} pages and #{contact_total} contacts for #{CONTROLLER[:company]}"
		begin
			(page[:start]..page[:end]).each do |i|
				company = Net::HTTP::Get.new("https://www.linkedin.com/vsearch/p?company=#{CONTROLLER[:company].gsub(/\s/, '%20')}&openAdvancedForm=true&companyScope=C&locationType=Y&f_N=A&page_num=#{i}", headers)
				REST_CLIENT.request(company) do |response|
					names = response.body.scan(/(\"fNameP\".*?)\,\"key\"/).to_a
					titles = response.body.scan(/(\"snippets\"\:\[.*?\])/).to_a

					names.zip(titles).each do |name, title|
						individual = []
						individual.push(name.to_s.tr('\\', '').gsub!(/\["/, '{').gsub!(/"\]/, '}').match(/\"fNameP.*?\"..(.*?)\"\,/)[1])
						individual.push(name.to_s.tr('\\', '').gsub!(/\["/, '{').gsub!(/"\]/, '}').match(/\"lNameP.*?\"..(.*?)\"/)[1])
						if title.to_s.match(/heading/)
							individual.push(title.to_s.tr('\\', '').match(/\"heading\"\:\"(.*?)\"/)[1].gsub!(/u003cBu003e|u003c\/Bu003e|u002d/, '').gsub(/&amp;/, '&'))
						end
						STORAGE.push(individual)
					end
					print "\r"
					print "[*] Crawling from #{i} to #{page[:end]}"
					$stdout.flush
					sleep 0.01
				end
				sleep rand(2..10) # To bypass script detection * Important, do not remove. *
			end	
		rescue Exception => e
			# Do nothing....
		end

	end

	def save_results
		puts "\n[*] Saving contacts to #{Dir.pwd}/#{CONTROLLER[:company].gsub(/\s/, '_')}_contacts.txt"
		File.open("#{CONTROLLER[:company].gsub(/\s/, '_')}_contacts.txt", 'a') do |file| 
			(0...STORAGE.size).each do |i|
				file.write("#{STORAGE[i][0]},#{STORAGE[i][1]},#{STORAGE[i][2]}\n")
			end
		end

	end

	def prompt(*args)
    	print(*args)
    	STDIN.noecho(&:gets).chomp
	end
}
