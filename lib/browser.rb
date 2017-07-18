class Browser

	def initialize(url)
		@url = url
		caps = Selenium::WebDriver::Remote::Capabilities.chrome(chrome_options: { detach: true })
		@driver = Watir::Browser.new :chrome, switches: ['--start-maximized'], desired_capabilities: caps
	end

	def login(username, pass)
		@driver.goto @url
		@driver.frame(name: 'ContentFrame').frame(name: 'ActiveAreaFrame').text_field(id: 'UserName').set username
		@driver.frame(name: 'ContentFrame').frame(name: 'ActiveAreaFrame').text_field(type: 'password').set(pass)
		@driver.frame(name: 'ContentFrame').frame(name: 'ActiveAreaFrame').text_field(type: 'password').send_keys :enter
		raise ArgumentError, 'Error logging in' if @driver.alert.exists?
		return self
	end

	def add_member(member_type, source_code, web_pin, card_type, card_num, auth_code)
		@driver.goto @url + 'fw1/index.cfm?action=member.addBasicDetails&mode=1'

		@driver.select_list(id: 'consumertypeid').select member_type
		@driver.text_field(id: 'forename').set 'Testuser'
		@driver.text_field(id: 'surname').set RandomWordGenerator.word
		@driver.text_field(id: 'countrycode').set 'UK'
		@driver.text_field(id: 'originalsourcecode').set source_code
		@driver.text_field(id: 'originalsourcecode').send_keys :enter

		@driver.goto @url + 'fw1/index.cfm?action=member.addAddressDetails'

		@driver.text_field(id: 'address1_1').send_keys :enter

		@driver.text_field(id: 'webPassword').set(web_pin)
		@driver.text_field(id: 'webPassword').send_keys :enter

		@driver.select_list(id: 'ccardType').select card_type
		@driver.text_field(id: 'ccardNumber').set card_num
		@driver.text_field(id: 'ccardExpiry').set '1220'
		@driver.text_field(id: 'creditCardAuthorisationCode').set(auth_code)
		@driver.text_field(id: 'creditCardAuthorisationCode').send_keys :enter

		@driver.goto @url

		@driver.frame(name: 'ContentFrame').frame(name: 'NavBarFrame').a(text: 'Membership').click
		@driver.frame(name: 'ContentFrame').frame(name: 'NavBarFrame').a(text: 'Basics').click
		return self
	end
end
