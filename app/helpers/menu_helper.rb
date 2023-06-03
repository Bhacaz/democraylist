# frozen_string_literal: true

module MenuHelper
  def self.items(*items)
    items.map do |identifier, label, link|
      Item.new(identifier, label, link)
    end
  end

  class Item
    include ActionView::Helpers::UrlHelper
    attr_reader :identifier, :label, :link
    def initialize(identifier, label, link)
      @identifier = identifier
      @label = label
      @link = link
    end

    def to_link
      link_to label, link, id: "menu-item-#{identifier}"
    end
  end
end
