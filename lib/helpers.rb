class Helpers
	def self.kill_chromedrivers
		`taskkill /f /im chromedriver.exe`
	end
end
