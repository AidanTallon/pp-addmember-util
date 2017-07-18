class MainWindow < Qt::MainWindow
  slots 'config()', 'kill_chrome()'

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

  def kill_chrome
    reply = Qt::MessageBox::question self, 'Are you sure?', 'Kill all chromedriver processes?', Qt::MessageBox::Yes, Qt::MessageBox::No
    Helpers.kill_chromedrivers if reply == 16384
  end

  def createActions
    @configAct = Qt::Action.new(tr("&Config"), self)
    @configAct.statusTip = tr("Change settings for environment")
    connect(@configAct, SIGNAL('triggered()'), self, SLOT('config()'))

    @killChromeAct = Qt::Action.new(tr("&Kill chromedriver processes"), self)
    @killChromeAct.statusTip = tr("End all current chromedriver processes")
    connect(@killChromeAct, SIGNAL('triggered()'), self, SLOT('kill_chrome()'))
  end

  def createMenus
    @settingsMenu = menuBar.addMenu(tr("&Settings"))
    @settingsMenu.addAction(@configAct)
    @settingsMenu.addSeparator

    @toolsMenu = menuBar.addMenu(tr("&Tools"))
    @toolsMenu.addAction(@killChromeAct)
    @toolsMenu.addSeparator
  end
end
