class ConfigDialog < Qt::Dialog
	slots 'saveConfig()'

	def initialize
		super

		self.windowTitle = tr("Config")

		username_label = Qt::Label.new 'Username:', self
		@usernameInput = Qt::LineEdit.new self
		@usernameInput.text = EnvConfig.user['username'] rescue ''

		password_label = Qt::Label.new 'Password:', self
		@passwordInput = Qt::LineEdit.new self
		@passwordInput.text = EnvConfig.user['password'] rescue ''

		url_label = Qt::Label.new 'Url:', self
		@urlInput = Qt::LineEdit.new self
		@urlInput.text = EnvConfig.url rescue ''

		@saveButton = Qt::PushButton.new 'Save', self
		connect(@saveButton, SIGNAL('clicked()'), self, SLOT('saveConfig()'))

		self.layout = Qt::GridLayout.new do |l|
			l.addWidget username_label, 0, 0
			l.addWidget @usernameInput, 0, 1

			l.addWidget password_label, 0, 2			
			l.addWidget @passwordInput, 0, 3

			l.addWidget url_label, 1, 0
			l.addWidget @urlInput, 1, 1, 1, 3

			l.addWidget @saveButton, 2, 1, 1, 3
		end
	end

	def saveConfig
		EnvConfig.save_user @usernameInput.text, @passwordInput.text
		EnvConfig.save_url @urlInput.text
		self.close
	end
end
