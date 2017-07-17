class MemberList < Qt::ListWidget

	def initialize
		super
	end

	def refresh
		clear
		MemberLog.all.each do |mem|
			add_member mem if mem.consumer_number
		end
	end

	def add_member(member)
		item = Qt::ListWidgetItem.new member.first_name + ' ' + member.last_name + ' - ' + member.consumer_number, self
		item.toolTip = "Member Type: #{member.member_type}\nSource Code: #{member.source_code}\nAuth Code: #{member.auth_code}\nWeb Pin: #{member.web_pin}"
	end
end
