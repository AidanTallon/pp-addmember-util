class MainWidget < Qt::Widget
  attr_reader :member_opts

  signals 'clicked()',
          'currentItemChanged()',
          'itemDoubleClicked()',
          'show_error(const QString&)',
          'update_mem_list()',
          'update_loading_widget()'

  slots 'add_member()',
        'login()',
        'kill_chrome()',
        'on_show_error(const QString&)',
        'refresh_mem_list()',
        'delete_mem_list()',
        'clear_mem_list()',
        'on_update_loading_widget()'

  @lock = Mutex.new

  def initialize(parent)
    super parent

    mem_type_options =
    [
      'Full Member Consumer',
      'Dummy Associate Consumer',
      'Bank Card Consumer',
      'Associate Consumer',
      'Bankcard Skeleton Consumer',
      'Hybrid Associate Consumer'
    ]

    card_type_options =
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

    mem_type_label = Qt::Label.new 'Member Type:', self
    mem_type_list = Qt::ListWidget.new self

    mem_type_options.each do |m|
      Qt::ListWidgetItem.new m, mem_type_list
    end

    card_type_label = Qt::Label.new 'Card Type:', self
    card_type_list = Qt::ListWidget.new self

    card_type_options.each do |c|
      Qt::ListWidgetItem.new c, card_type_list
    end

    source_code_label = Qt::Label.new 'Source Code:', self
    source_code_input = Qt::LineEdit.new self

    card_num_label = Qt::Label.new 'Card Number:', self
    card_num_input = Qt::LineEdit.new self

    auth_code_label = Qt::Label.new 'Authorisation Code:', self
    auth_code_input = Qt::LineEdit.new self

    web_pin_label = Qt::Label.new 'Web Pin:', self
    web_pin_input = Qt::LineEdit.new self

    @member_opts = MemberOptions.new(mem_type_list,
                                     card_type_list,
                                     source_code_input,
                                     card_num_input,
                                     auth_code_input,
                                     web_pin_input)

    login_button = Qt::PushButton.new 'Just log me in', self
    connect(login_button, SIGNAL('clicked()'), self, SLOT('login()'))

    add_mem_button = Qt::PushButton.new 'Add Member', self
    connect(add_mem_button, SIGNAL('clicked()'), self, SLOT('add_member()'))

    @member_list = MemberList.new

    @clear_mem_list_button = Qt::PushButton.new 'Clear', self
    connect(@clear_mem_list_button, SIGNAL('clicked()'), self, SLOT('clear_mem_list()'))

    @delete_mem_list_button = Qt::PushButton.new 'Delete', self
    connect(@delete_mem_list_button, SIGNAL('clicked()'), self, SLOT('delete_mem_list()'))

    @loading_widget = Qt::Label.new 'adding member...', self

    layout = Qt::GridLayout.new do |l|
      selectors = Qt::GridLayout.new

      presets = PresetsWidget.new self, @member_opts
      selectors.addWidget presets, 0, 0, 4, 1

      mem_type = Qt::VBoxLayout.new
      mem_type.addWidget mem_type_label
      mem_type.addWidget mem_type_list
      selectors.addLayout mem_type, 0, 1, 4, 1

      card_type = Qt::VBoxLayout.new
      card_type.addWidget card_type_label
      card_type.addWidget card_type_list
      selectors.addLayout card_type, 0, 2, 4, 1

      source_code = Qt::VBoxLayout.new
      source_code.addWidget source_code_label
      source_code.addWidget source_code_input
      selectors.addLayout source_code, 0, 3, Qt::AlignTop

      card_num = Qt::VBoxLayout.new
      card_num.addWidget card_num_label
      card_num.addWidget card_num_input
      selectors.addLayout card_num, 1, 3, Qt::AlignTop

      auth_code = Qt::VBoxLayout.new
      auth_code.addWidget auth_code_label
      auth_code.addWidget auth_code_input
      selectors.addLayout auth_code, 2, 3, Qt::AlignTop

      web_pin = Qt::VBoxLayout.new
      web_pin.addWidget web_pin_label
      web_pin.addWidget web_pin_input
      selectors.addLayout web_pin, 3, 3, Qt::AlignTop

      buttons = Qt::VBoxLayout.new
      buttons.addWidget login_button
      buttons.addWidget add_mem_button

      l.addLayout selectors, 0, 0, 5, 4
      l.addLayout buttons, 0, 4, Qt::AlignTop

      l.addWidget @member_list, 0, 5, 5, 1
      l.addWidget @loading_widget, 0, 6, Qt::AlignTop
      @loading_widget.hide
      l.addWidget @delete_mem_list_button, 3, 6
      l.addWidget @clear_mem_list_button, 4, 6
    end
    setLayout layout

    connect self, SIGNAL('show_error(const QString&)'), self, SLOT('on_show_error(const QString&)')
    connect self, SIGNAL('update_mem_list()'), self, SLOT('refresh_mem_list()')

    connect self, SIGNAL('update_loading_widget()'), self, SLOT('on_update_loading_widget()')

    @adding_member = 0
  end

  def add_member
    mem   = @member_opts.read_member_type
    scode = @member_opts.read_source_code
    ctype = @member_opts.read_card_type
    cnum  = @member_opts.read_card_number
    acode = @member_opts.read_auth_code
    wpin  = @member_opts.read_web_pin

    username = EnvConfig.user['username']
    password = EnvConfig.user['password']
    url = EnvConfig.url

    member = MemberLog.new

    semaphore = Mutex.new

    Thread.new do
      semaphore.synchronize do

        @adding_member += 1
        emit update_loading_widget()

        begin
          Browser.new(url).login(username, password).add_member(mem, scode, wpin, ctype, cnum, acode, member)
        rescue Exception => e
          emit show_error "#{e}\n#{e.backtrace}"
        end

        emit update_mem_list()
        @adding_member -= 1
        emit update_loading_widget()
      end
    end
  end


  def on_show_error(msg)
    Qt::ErrorMessage.new.showMessage(msg)
  end

  def on_update_loading_widget
    @loading_widget.hide if @adding_member == 0
    @loading_widget.show if @adding_member > 0
  end

  def login
    username = EnvConfig.user['username']
    password = EnvConfig.user['password']
    url = EnvConfig.url

    Thread.new do
      begin
        Browser.new(url).login(username, password)
      rescue Exception => e
        emit show_error "#{e}"
      end
    end
  end

  def refresh_mem_list
    @member_list.refresh
  end

  def delete_mem_list
    return if @member_list.selectedItems[0].nil?
    member_name = @member_list.selectedItems[0].text
    MemberLog.all.delete_if do |m|
      "#{m.first_name} #{m.last_name} - #{m.consumer_number}" == member_name
    end
    @member_list.takeItem(@member_list.currentRow)
  end

  def clear_mem_list
    @member_list.clear
    MemberLog.all.clear
  end
end
