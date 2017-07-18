class MemberListWidget < Qt::Widget
  signals :clicked

  slots :delete_from_mem_list,
        :clear_mem_list

  def initialize(parent = nil)
    super

    @list_widget = MemberList.new

    delete_btn = Qt::PushButton.new 'Delete', self
    connect delete_btn, SIGNAL('clicked()'), self, SLOT('delete_from_mem_list()')

    clear_btn = Qt::PushButton.new 'Clear', self
    connect clear_btn, SIGNAL('clicked()'), self, SLOT('clear_mem_list()')

    @loading_label = Qt::Label.new 'adding member...'

    layout = Qt::GridLayout.new do |l|
      l.addWidget @list_widget, 1, 0, 1, 2
      l.addWidget delete_btn, 2, 0
      l.addWidget clear_btn, 2, 1
      l.addWidget @loading_label, 1, 0
      @loading_label.hide
    end

    setLayout layout
  end

  def refresh
    @list_widget.refresh
  end

  def delete_from_mem_list
    member_name = @list_widget.selectedItems[0].text
    MemberLog.all.delete_if do |m|
      (m.first_name + ' ' + m.last_name + ' - ' + m.consumer_number) == member_name
    end
    @list_widget.takeItem @list_widget.currentRow
  end

  def clear_mem_list
    @list_widget.clear
    MemberLog.all.clear
  end

  def show_loading
    @loading_label.show
  end

  def hide_loading
    @loading_label.hide
  end
end
