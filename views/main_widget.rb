class MainWidget < Qt::Widget
	attr_reader :member_type, :source_code, :card_type, :card_number, :auth_code, :web_pin

	signals 'clicked()', 'currentItemChanged()', 'itemDoubleClicked()'
	slots 'add_member()', 'load_preset()', 'login()', 'save_preset()', 'change_preset_name()', 'save_preset_name()', 'delete_preset()'

	def initialize(parent)
		super parent

		@member_type_list = 
		[
			'Full Member Consumer',
			'Dummy Associate Consumer', 
			'Bank Card Consumer', 
			'Associate Consumer',
		    'Bankcard Skeleton Consumer', 
		    'Hybrid Associate Consumer'
		]

		@card_type_list =
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

		login_button = Qt::PushButton.new 'Just log me in', self
		connect(login_button, SIGNAL('clicked()'), self, SLOT('login()'))

		add_mem_button = Qt::PushButton.new 'Add Member', self
		connect(add_mem_button, SIGNAL('clicked()'), self, SLOT('add_member()'))

		save_preset_button = Qt::PushButton.new 'Save Preset', self
		connect(save_preset_button, SIGNAL('clicked()'), self, SLOT('save_preset()'))

		presets_label = Qt::Label.new 'Presets:', self
		@presets = Qt::ListWidget.new self
		YAML.load(File.new './settings.yml')['saved_presets'].each do |preset|
			item = Qt::ListWidgetItem.new preset['name'], @presets
		end
		connect(@presets, SIGNAL('itemClicked(QListWidgetItem *)'), self, SLOT('load_preset()'))
		connect(@presets, SIGNAL('itemDoubleClicked(QListWidgetItem *)'), self, SLOT('change_preset_name()'))

		mem_type_label = Qt::Label.new 'Member Type:', self
		@member_type = Qt::ListWidget.new self

		@member_type_list.each do |m|
			Qt::ListWidgetItem.new m, @member_type
		end

		@member_type.setCurrentRow 0

		source_code_label = Qt::Label.new 'Source Code:', self
		@source_code = Qt::LineEdit.new self

		@source_code.text = 'WPUN'

		card_type_label = Qt::Label.new 'Credit Card Type:', self
		@card_type = Qt::ListWidget.new self

		@card_type_list.each do |c|
			Qt::ListWidgetItem.new c, @card_type
		end

		@card_type.setCurrentRow 5

		card_num_label = Qt::Label.new 'Credit Card Number:', self
		@card_number = Qt::LineEdit.new self

		@card_number.text = '4444333322221111'

		auth_code_label = Qt::Label.new 'Authorisation Code:', self
		@auth_code = Qt::LineEdit.new self

		@auth_code.text = 'UAT'

		web_pin_label = Qt::Label.new 'Web Pin:', self
		@web_pin = Qt::LineEdit.new self

		@web_pin.text = '1234'

		layout = Qt::GridLayout.new

		layout.addWidget presets_label, 	0, 0
		layout.addWidget @presets, 			1, 0

		layout.addWidget mem_type_label,    0, 1
		layout.addWidget @member_type,      1, 1

		layout.addWidget source_code_label, 0, 2
		layout.addWidget @source_code,      1, 2, Qt::AlignTop

		layout.addWidget card_type_label, 	0, 3
		layout.addWidget @card_type, 		1, 3

		layout.addWidget card_num_label, 	0, 4
		layout.addWidget @card_number, 		1, 4, Qt::AlignTop

		layout.addWidget auth_code_label, 	0, 5
		layout.addWidget @auth_code, 		1, 5, Qt::AlignTop

		layout.addWidget web_pin_label, 	0, 6
		layout.addWidget @web_pin, 			1, 6, Qt::AlignTop

		layout.addWidget login_button,		0, 7
		layout.addWidget add_mem_button, 	1, 7
		layout.addWidget save_preset_button, 2, 7

		setLayout layout
	end

	def add_member
		mem   = @member_type.selectedItems[0].text
		scode = @source_code.text
		ctype = @card_type.selectedItems[0].text
		cnum  = @card_number.text
		acode = @auth_code.text
		wpin  = @web_pin.text

		username = EnvConfig.user['username']
		password = EnvConfig.user['password']
		url = EnvConfig.url

		Thread.new { Browser.new(url).login(username, password).add_member(mem, scode, wpin, ctype, cnum, acode) }
	end

	def login
		username = EnvConfig.user['username']
		password = EnvConfig.user['password']
		url = EnvConfig.url

		Thread.new { Browser.new(url).login(username, password) }
	end

	def load_preset
		all_presets = YAML.load(File.new('./settings.yml'))['saved_presets']
		preset = all_presets.find { |p| p['name'] == @presets.selectedItems[0].text }

		@member_type.setCurrentRow @member_type_list.index preset['member_type']
		@source_code.text = preset['source_code']
		@card_type.setCurrentRow @card_type_list.index preset['ccard_type']
		@card_number.text = preset['ccard_num'].to_s
		@auth_code.text = preset['auth_code']
		@web_pin.text = preset['web_pin'].to_s
	end

	def save_preset
		yaml_file = YAML.load(File.new('./settings.yml'))
		all_presets = yaml_file['saved_presets']
		preset = {}
		preset['name'] = new_preset_name
		preset['member_type'] = @member_type.selectedItems[0].text
		preset['source_code'] = @source_code.text
		preset['ccard_type'] = @card_type.selectedItems[0].text
		preset['ccard_num'] = @card_number.text.to_i
		preset['auth_code'] = @auth_code.text
		preset['web_pin'] = @web_pin.text.to_i

		all_presets.push preset

		File.open('./settings.yml', 'w') { |f| f.write yaml_file.to_yaml }

		item = Qt::ListWidgetItem.new preset['name'], @presets
	end

	def new_preset_name(current_index = 1)
		all_presets = YAML.load(File.new('./settings.yml'))['saved_presets']
		if all_presets.any? { |preset| preset['name'] == "new preset #{current_index}" }
			return new_preset_name(current_index + 1)
		else
			return "new preset #{current_index}"
		end
	end

	def change_preset_name
		d = Qt::Dialog.new
		d.windowTitle = 'Edit preset'
		@change_preset_name_dialog = d

		input_label = Qt::Label.new 'Name:', d

		input = Qt::LineEdit.new d
		input.text = @presets.selectedItems[0].text
		@change_preset_name_input = input
		btn = Qt::PushButton.new 'Save', d
		connect(btn, SIGNAL('clicked()'), self, SLOT("save_preset_name()"))

		delete_btn = Qt::PushButton.new 'Delete', d
		connect(delete_btn, SIGNAL('clicked()'), self, SLOT('delete_preset()'))

		d.layout = Qt::GridLayout.new do |l|
			l.addWidget input_label, 0, 0
			l.addWidget input,		 0, 1, 1, 2
			l.addWidget btn,		 1, 1
			l.addWidget delete_btn,	 1, 2
		end

		d.show
	end

	def save_preset_name
		new_name = @change_preset_name_input.text
		yaml_file = YAML.load(File.new('./settings.yml'))
		all_presets = yaml_file['saved_presets']
		preset = all_presets.find { |p| p['name'] == @presets.selectedItems[0].text }
		preset['name'] = new_name

		File.open('./settings.yml', 'w') { |f| f.write yaml_file.to_yaml }
		@change_preset_name_dialog.close
		@presets.selectedItems[0].text = new_name
	end

	def delete_preset
		yaml_file = YAML.load(File.new('./settings.yml'))
		all_presets = yaml_file['saved_presets']
		all_presets.delete_if { |p| p['name'] == @presets.selectedItems[0].text }

		File.open('./settings.yml', 'w') { |f| f.write yaml_file.to_yaml }
		@change_preset_name_dialog.close
		@presets.takeItem(@presets.currentRow)
	end
end
