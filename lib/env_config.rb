class EnvConfig
  @yaml_data
  @path

  def self.load_data(path)
    @path = path
    if File.exists? path
      @yaml_data = YAML.load(File.new(path))
    else
      @yaml_data =
        {
          'env' =>
          {
            'url' => '',
            'saved_urls' => []
          },
          'user' =>
          {
            'username' => '',
            'password' => ''
          }
        }
      File.open(path, 'w') { |f| f.write @yaml_data.to_yaml }
    end
  end

  def self.user
    @yaml_data['user']
  end

  def self.save_user(username, password)
    @yaml_data = YAML.load(File.new(@path))
    @yaml_data['user']['username'] = username
    @yaml_data['user']['password'] = password
    File.open(@path, 'w') { |f| f.write @yaml_data.to_yaml }
  end

  def self.url
    @yaml_data['env']['url']
  end

  def self.saved_urls
    @yaml_data['env']['saved_urls']
  end

  def self.save_url(url)
    @yaml_data = YAML.load(File.new(@path))
    @yaml_data['env']['url'] = url
    unless  @yaml_data['env']['saved_urls'].include? url
      @yaml_data['env']['saved_urls'] << url
    end
    File.open(@path, 'w') { |f| f.write @yaml_data.to_yaml }
  end
end
