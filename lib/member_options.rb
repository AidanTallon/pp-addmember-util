class MemberOptions

  def initialize(mem_type_list, card_type_list, source_code_input, card_num_input, auth_code_input, web_pin_input)
    @member_type = mem_type_list
    @card_type = card_type_list
    @source_code = source_code_input
    @card_num = card_num_input
    @auth_code = auth_code_input
    @web_pin = web_pin_input
  end

  def set_member_type(value)
    set_list_value @member_type, value
  end

  def read_member_type
    read_list_value @member_type
  end

  def set_card_type(value)
    set_list_value @card_type, value
  end

  def read_card_type
    read_list_value @card_type
  end

  def set_source_code(value)
    set_input_value @source_code, value
  end

  def read_source_code
    read_input_value @source_code
  end

  def set_card_number(value)
    set_input_value @card_num, value
  end

  def read_card_number
    read_input_value @card_num
  end

  def set_auth_code(value)
    set_input_value @auth_code, value
  end

  def read_auth_code
    read_input_value @auth_code
  end

  def set_web_pin(value)
    set_input_value @web_pin, value
  end

  def read_web_pin
    read_input_value @web_pin
  end

  private

  def set_list_value(list, value)
    list.count.times do |i|
      if list.item(i).text == value
        list.setCurrentRow i
        break
      end
    end
  end

  def read_list_value(list)
    list.selectedItems[0].text
  end

  def set_input_value(input, value)
    input.text = value
  end

  def read_input_value(input)
    input.text
  end
end
