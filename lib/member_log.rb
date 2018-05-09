class MemberLog
  attr_accessor :member_type, :source_code, :web_pin, :card_type, :card_num, :auth_code, :first_name, :last_name, :consumer_number,:membership_number, :external_identifier

  def initialize
    @@all ||= []
    @@all << self
  end

  def self.all
    @@all ||= []
  end

  def info
    s =  "Consumer Number: #{@consumer_number}\n"
    s += "Source Code: #{@source_code}\n"
    s += "Membership Number: #{@membership_number}\n"
    s += "External Identifier: #{@external_identifier}\n"
    s += "Web Pin: #{@web_pin}\n"
  end
end
