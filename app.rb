require 'Qt'
require 'random_word_generator'
require 'watir'
require 'yaml'

Dir['./lib/*.rb'].each { |f| require f }
Dir['./views/*.rb'].each { |f| require f }
Dir['./models/*.rb'].each { |f| require f }

EnvConfig.load_data './data.yml'

$member_options = MemberOptions.new

app = Qt::Application.new ARGV

window = MainWindow.new

window.show

app.exec
