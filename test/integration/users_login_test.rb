# frozen_string_literal: true

require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  test 'login with invalid information' do
    get login_path
    assert_response :success
    post login_path, params: { session: { email: '', password: '' } }
    assert_response :unprocessable_entity
    assert_select 'title', full_title('Log in')
    assert_not flash.empty?
    assert_select '.alert.alert-danger', text: 'Invalid email/password combination'
    get root_path
    assert flash.empty?
    assert_select '.alert.alert-danger', count: 0
  end
end
