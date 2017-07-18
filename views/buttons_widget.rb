class ButtonsWidget < Qt::Widget
  signals :clicked

  def initialize(parent = nil)
    super

    login_button = Qt::PushButton.new 'Just log me in', self
    connect login_button, SIGNAL('clicked()'), parent, SLOT('login()')

    add_mem_button = Qt::PushButton.new 'Add Member', self
    connect add_mem_button, SIGNAL('clicked()'), parent, SLOT('add_member()')
  
    layout = Qt::HBoxLayout.new do |l|
      l.addWidget add_mem_button, Qt::AlignTop
      l.addWidget login_button, Qt::AlignTop
    end

    setLayout layout
  end
end
