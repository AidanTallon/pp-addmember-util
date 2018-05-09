class BasicsDetailsTable

    def initialize(browser)
        @browser = browser
    end

    def consumer_number
        table["Consumer Number"]
    end

    def membership_number
        header = @browser.frame(name: 'ContentFrame').frame(name: 'ActiveAreaFrame').div(text: /^Membership Number \d+/)
        match = /^Membership Number (\d+)/.match(header.text)

        match[1]
    end

    def external_identifier
        table["External Identifier"]
    end

    def table
        if @table.nil?
            element = @browser.frame(name: 'ContentFrame').frame(name: 'ActiveAreaFrame').input(id: 'update-credit-cards')
            element = element.parent until element.tag_name == 'tbody'

            trs = element.trs

            dict = {}

            trs.each do |tr|
                dict[tr.td.text] = tr.tds[1].text if tr.tds.length == 2
            end

            @table = dict
        end

        @table
    end
end