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

  def add_member(member_type, source_code, web_pin, card_type, card_num, auth_code, member_obj = nil)
    @driver.goto @url + 'fw1/index.cfm?action=member.addBasicDetails&mode=1'

    @driver.select_list(id: 'consumertypeid').select member_type
    first_name = 'TestUser'
    @driver.text_field(id: 'forename').set first_name
    last_name = RandomWordGenerator.word
    @driver.text_field(id: 'surname').set last_name
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

    unless member_obj.nil?
      member_obj.member_type = member_type
      member_obj.source_code = source_code
      member_obj.web_pin = web_pin
      member_obj.card_type = card_type
      member_obj.card_num = card_num
      member_obj.auth_code = auth_code
      member_obj.first_name = first_name
      member_obj.last_name = last_name
      member_obj.consumer_number = @driver.frame(name: 'MessageFrame').span(id: 'CurrentConsumerText').text.split(' ')[0]
    end

    return self
  end
end
