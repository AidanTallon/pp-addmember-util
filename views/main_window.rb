class MainWindow < Qt::MainWindow
	slots 'config()'

	def initialize
		super

		self.windowIcon = Qt::Icon.new './ppass.png'
		self.windowTitle = 'PP Utilities'

		@widget = MainWidget.new self
		setCentralWidget(@widget)

		createActions
		createMenus
	end

	def config
		ConfigDialog.new.show
	end

	def createActions
		@configAct = Qt::Action.new(tr("&Config"), self)
		@configAct.statusTip = tr("Change settings for environment")
		connect(@configAct, SIGNAL('triggered()'), self, SLOT('config()'))
	end

	def createMenus
		@settingsMenu = menuBar.addMenu(tr("&Settings"))
		@settingsMenu.addAction(@configAct)
		@settingsMenu.addSeparator
	end
end