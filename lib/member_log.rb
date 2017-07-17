class MemberLog
	attr_accessor :member_type, :source_code, :web_pin, :card_type, :card_num, :auth_code, :first_name, :last_name, :consumer_number

	def initialize
		@@all ||= []
		@@all << self
	end

	def self.all
		@@all ||= []
	end
end
