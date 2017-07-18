class MemberOptionsWidget < Qt::Widget
  attr_accessor :member_type, :source_code, :card_type, :card_number, :auth_code, :web_pin

  signals :update

  slots :on_update

  def initialize(parent, buttons_widget)
    super parent

    mem_types = 
    [
      'Full Member Consumer',
      'Dummy Associate Consumer',
      'Bank Card Consumer',
      'Associate Consumer',
      'Bankcard Skeleton Consumer',
      'Hybrid Associate Consumer'
    ]

    card_types =
    [
      'MP',
      'MC',
      'AX',
      'EO',
      'UP',
      'VS',
      'BA',
      'DC',
      'DS'
    ]

    @mem_type_items = {}

    @card_type_items = {}

    mem_type_label = Qt::Label.new 'Member Type:', self
    @mem_type_list = Qt::ListWidget.new self

    mem_types.each do |m|
      @mem_type_items[m] = Qt::ListWidgetItem.new m, @mem_type_list
    end

    source_code_label = Qt::Label.new 'Source Code:', self
    @source_code_input = Qt::LineEdit.new self

    card_type_label = Qt::Label.new 'Credit Card Type:', self
    @card_type_list = Qt::ListWidget.new self

    card_types.each do |c|
      @card_type_items[c] = Qt::ListWidgetItem.new c, @card_type_list
    end

    card_num_label = Qt::Label.new 'Credit Card Number:', self
    @card_num_input = Qt::LineEdit.new self

    auth_code_label = Qt::Label.new 'Authorisation Code:', self
    @auth_code_input = Qt::LineEdit.new self

    web_pin_label = Qt::Label.new 'Web Pin:', self
    @web_pin_input = Qt::LineEdit.new self

    layout = Qt::GridLayout.new do |l|
      l.addWidget mem_type_label, 0, 0
      l.addWidget @mem_type_list, 1, 0

      l.addWidget card_type_label, 0, 1
      l.addWidget @card_type_list, 1, 1

      labels_inputs = Qt::GridLayout.new do |li|
          li.addWidget source_code_label, 0, 0
          li.addWidget card_num_label,    1, 0
          li.addWidget auth_code_label,   2, 0
          li.addWidget web_pin_label,     3, 0

          li.addWidget @source_code_input, 0, 1
          li.addWidget @card_num_input,    1, 1
          li.addWidget @auth_code_input,   2, 1
          li.addWidget @web_pin_input,     3, 1

          li.addWidget buttons_widget, 4, 0, 1, 2
      end

      l.addLayout labels_inputs, 1, 2, Qt::AlignTop
    end

    setLayout layout
  end

  def on_update
    @mem_type_list.setCurrentItem(@mem_type_items[$member_options.member_type])
    @source_code_input.text = $member_options.source_code
    @card_type_list.setCurrentItem(@card_type_items[$member_options.card_type])
    @card_num_input.text = $member_options.card_number
    @auth_code_input.text = $member_options.auth_code
    @web_pin_input.text = $member_options.web_pin
  end
end
