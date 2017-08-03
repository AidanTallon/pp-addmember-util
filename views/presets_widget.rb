class PresetsWidget < Qt::Widget
  signals 'itemClicked()',
          'itemDoubleClicked()'

  slots 'load_preset()',
        'open_preset_dialog()',
        'save_preset_name()',
        'delete_preset()',
        'save_preset()'

  def initialize(parent, member_opts)
    super parent

    @member_opts = member_opts

    label = Qt::Label.new 'Presets:', self
    @list = Qt::ListWidget.new self
    YAML.load(File.new './settings.yml')['saved_presets'].each do |preset|
      item = Qt::ListWidgetItem.new preset['name'], @list
    end
    connect @list, SIGNAL('itemClicked(QListWidgetItem *)'), self, SLOT('load_preset()')
    connect @list, SIGNAL('itemDoubleClicked(QListWidgetItem *)'), self, SLOT('open_preset_dialog()')

    save_btn = Qt::PushButton.new 'Save Preset', self
    connect save_btn, SIGNAL('clicked()'), self, SLOT('save_preset()')

    layout = Qt::VBoxLayout.new do |l|
      l.addWidget label
      l.addWidget @list
      l.addWidget save_btn
    end

    setLayout layout
  end

  def load_preset
    all_presets = YAML.load(File.new('./settings.yml'))['saved_presets']
    preset = all_presets.find { |p| p['name'] == @list.selectedItems[0].text }

    @member_opts.set_member_type preset['member_type']
    @member_opts.set_source_code preset['source_code']
    @member_opts.set_card_type preset['ccard_type']
    @member_opts.set_card_number preset['ccard_num'].to_s
    @member_opts.set_auth_code preset['auth_code']
    @member_opts.set_web_pin preset['web_pin'].to_s
  end

  def save_preset
    yaml_file = YAML.load(File.new('./settings.yml'))
    all_presets = yaml_file['saved_presets']
    preset = {}
    preset['name'] = new_preset_name
    preset['member_type'] = @member_opts.read_member_type
    preset['source_code'] = @member_opts.read_source_code
    preset['ccard_type'] = @member_opts.read_card_type
    preset['ccard_num'] = @member_opts.read_card_number.to_i
    preset['auth_code'] = @member_opts.read_auth_code
    preset['web_pin'] = @member_opts.read_web_pin.to_i

    all_presets.push preset

    File.open('./settings.yml', 'w') { |f| f.write yaml_file.to_yaml }

    item = Qt::ListWidgetItem.new preset['name'], @list
  end

  def new_preset_name(current_index = 1)
    all_presets = YAML.load(File.new('./settings.yml'))['saved_presets']
    if all_presets.any? { |preset| preset['name'] == "new preset #{current_index}" }
      return new_preset_name(current_index + 1)
    else
      return "new preset #{current_index}"
    end
  end

  def open_preset_dialog
    d = Qt::Dialog.new
    d.windowTitle = 'Edit preset'
    @change_preset_name_dialog = d # feel like there's a better way of doing this than with instance var

    input_label = Qt::Label.new 'Name: ', d

    input = Qt::LineEdit.new d
    input.text = @list.selectedItems[0].text
    @change_preset_name_input = input
    btn = Qt::PushButton.new 'Save', d
    connect btn, SIGNAL('clicked()'), self, SLOT("save_preset_name()")

    delete_btn = Qt::PushButton.new 'Delete', d
    connect delete_btn, SIGNAL('clicked()'), self, SLOT('delete_preset()')

    d.layout = Qt::GridLayout.new do |l|
      l.addWidget input_label, 0, 0
      l.addWidget input,       0, 1, 1, 2
      l.addWidget btn,         1, 1
      l.addWidget delete_btn,  1, 2
    end

    d.show
  end

  def save_preset_name
    new_name = @change_preset_name_input.text
    yaml_file = YAML.load(File.new('./settings.yml'))
    all_presets = yaml_file['saved_presets']
    preset = all_presets.find { |p| p['name'] == @list.selectedItems[0].text }
    preset['name'] = new_name

    File.open('./settings.yml', 'w') { |f| f.write yaml_file.to_yaml }
    @change_preset_name_dialog.close
    @list.selectedItems[0].text = new_name
  end

  def delete_preset
    return if @list.selectedItems[0].nil?

    reply = Qt::MessageBox::question self, 'Are you sure?', "Delete preset #{@list.selectedItems[0].text}?", Qt::MessageBox::Yes, Qt::MessageBox::No
    if reply == 16384
      yaml_file = YAML.load(File.new('./settings.yml'))
      all_presets = yaml_file['saved_presets']
      all_presets.delete_if { |p| p['name'] == @list.selectedItems[0].text }

      File.open('./settings.yml', 'w') { |f| f.write yaml_file.to_yaml }
      @change_preset_name_dialog.close
      @list.takeItem @list.currentRow
    end
  end
end
