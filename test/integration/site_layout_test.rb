# frozen_string_literal: true

require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  test 'layout links' do
    get root_path
    assert_response :success
    assert_select 'title', full_title
    assert_select 'a[href=?]', root_path, count: 2
    assert_select 'a[href=?]', help_path
    assert_select 'a[href=?]', about_path
    assert_select 'a[href=?]', contact_path
    assert_select 'a[href=?]', signup_path, text: 'Sign up now!'

    get contact_path
    assert_response :success
    assert_select 'title', full_title('Contact')

    get signup_path
    assert_response :success
    assert_select 'title', full_title('Sign up')
    assert_select 'h1', 'Sign up'
  end
end
