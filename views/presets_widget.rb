class PresetsWidget < Qt::Widget

  signals 'itemClicked(QListWidgetItem *)',
          'itemDoubleClicked(QListWidgetItem *)',
          :clicked

  slots :load_preset,
        :change_preset_name,
        :save_preset,
        :delete_preset,
        :save_preset_name

  def initialize(parent = nil)
    super

    @list_widget = Qt::ListWidget.new self

    YAML.load(File.new './settings.yml')['saved_presets'].each do |preset|
      item = Qt::ListWidgetItem.new preset['name'], @list_widget
    end

    connect @list_widget, SIGNAL('itemClicked(QListWidgetItem *)'), self, SLOT('load_preset()')
    connect @list_widget, SIGNAL('itemDoubleClicked(QListWidgetItem *)'), self, SLOT('change_preset_name()')

    presets_label = Qt::Label.new 'Presets:', self

    save_preset_button = Qt::PushButton.new 'Save Preset', self
    connect save_preset_button, SIGNAL('clicked()'), self, SLOT('save_preset()')

    layout = Qt::VBoxLayout.new do |l|
      l.addWidget presets_label
      l.addWidget @list_widget, Qt::AlignTop
      l.addWidget save_preset_button
    end

    @list_widget.setCurrentRow 0

    setLayout layout
  end

  def load_preset
    all_presets = YAML.load(File.new('./settings.yml'))['saved_presets']
    preset = all_presets.find { |p| p['name'] == @list_widget.selectedItems[0].text }

    $member_options.member_type = preset['member_type']
    $member_options.source_code = preset['source_code']
    $member_options.card_type = preset['ccard_type']
    $member_options.card_number = preset['ccard_num'].to_s
    $member_options.auth_code = preset['auth_code']
    $member_options.web_pin = preset['web_pin'].to_s

    $member_options_widget.on_update
  end

  def change_preset_name
    d = Qt::Dialog.new
    d.windowTitle = 'Edit preset'

    input_label = Qt::Label.new 'Name:', d

    input = Qt::LineEdit.new d
    input.text = @list_widget.selectedItems[0].text

    btn = Qt::PushButton.new 'Save', d
    connect btn, SIGNAL('clicked()'), self, SLOT('save_preset_name()')

    delete_btn = Qt::PushButton.new 'Delete', d
    connect delete_btn, SIGNAL('clicked()'), self, SLOT('delete_preset()')

    d.layout = Qt::GridLayout.new do |l|
      l.addWidget input_label, 0, 0
      l.addWidget input,       0, 1, 1, 2
      l.addWidget btn,         1, 1
      l.addWidget delete_btn   1, 2
    end

    @change_name_dialog = d
    @change_name_input = input

    d.show
  end

  def save_preset_name
    new_name = @change_name_input.text
    yaml_file = YAML.load(File.new('./settings.yml'))
    all_presets = yaml_file['save_presets']
    preset = all_presets.find { |p| p['name'] == @list_widget.selectedItems[0].text }
    preset['name'] = new_name

    File.open('./settings.yml', 'w') { |f| f.write yaml_file.to_yaml }
    @change_name_dialog.close
    @list_widget.selectedItems[0].text = new_name
  end

  def save_preset
    yaml_file = YAML.load(File.new('./settings.yml'))
    all_presets = yaml_file['saved_presets']
    preset = {}

    preset['name'] = new_preset_name
    preset['member_type'] = MemberOptions.member_type
    preset['source_code'] = MemberOptions.source_code
    preset['ccard_type'] = MemberOptions.card_type
    preset['ccard_num'] = MemberOptions.card_number.to_i
    preset['auth_code'] = MemberOptions.auth_code
    preset['web_pin'] = MemberOptions.web_pin.to_i

    all_presets.push preset

    File.open('./settings.yml', 'w') { |f| f.write yaml_file.to_yaml }

    item = Qt::ListWidgetItem.new preset['name'], @list_widget
  end

  def new_preset_name(current_index = 1)
    all_presets = YAML.load(File.new('./settings.yml'))['save_presets']
    if all_presets.any? { |preset| preset['name'] == "new preset #{current_index}" }
      return new_preset_name(current_index + 1)
    else
      return "new preset #{current_index}"
    end
  end

  def delete_preset
    yaml_file = YAML.load(File.new('./settings.yml'))
    all_presets = yaml_file['save_presets']
    all_presets.delete_if { |p| p['name'] == @list_widget.selectedItems[0].text }

    File.open('./settings.yml', 'w') { |f| f.write yaml_file.to_yaml }
    @change_name_dialog.close
    @list_widget.takeItem @list_widget.currentRow
  end
end
