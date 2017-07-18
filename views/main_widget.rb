class MainWidget < Qt::Widget
  attr_reader :member_type, :source_code, :card_type, :card_number, :auth_code, :web_pin

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

  def initialize(parent)
    super parent

    @presets = PresetsWidget.new self

    @buttons_widget = ButtonsWidget.new self

    $member_options_widget = MemberOptionsWidget.new self, @buttons_widget

    @member_list_widget = MemberListWidget.new self

    layout = Qt::GridLayout.new do |l|
      l.addWidget @presets, 0, 0

      l.addWidget $member_options_widget, 0, 1

      l.addWidget @member_list_widget, 0, 2
    end

    setLayout layout

    @presets.load_preset

    $member_options_widget.on_update

    connect self, SIGNAL('show_error(const QString&)'), self, SLOT('on_show_error(const QString&)')
    connect self, SIGNAL('update_mem_list()'), self, SLOT('refresh_mem_list()')

    connect self, SIGNAL('update_loading_widget()'), self, SLOT('on_update_loading_widget()')

    @adding_member = 0
  end

  def add_member
    mem   = $member_options.member_type
    scode = $member_options.source_code
    ctype = $member_options.card_type
    cnum  = $member_options.card_number
    acode = $member_options.auth_code
    wpin  = $member_options.web_pin

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
          emit show_error "#{e}"
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
    @member_list_widget.hide_loading if @adding_member == 0
    @member_list_widget.show_loading if @adding_member > 0
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
    @member_list_widget.refresh
  end
end
