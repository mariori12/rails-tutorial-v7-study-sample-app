# frozen_string_literal: true

require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  test 'gravatar uses lowercase email and supports custom sizes' do
    user = User.new(name: 'Example User', email: 'USER@example.com')
    expected_url = 'https://secure.gravatar.com/avatar/b58996c504c5638798eb6b511e6f49af'
    default_image = Nokogiri::HTML.fragment(gravatar_for(user)).at_css('img')
    assert_equal "#{expected_url}?s=80", default_image['src']
    assert_equal user.name, default_image['alt']
    small_image = Nokogiri::HTML.fragment(gravatar_for(user, size: 50)).at_css('img')
    assert_equal "#{expected_url}?s=50", small_image['src']
  end
end
