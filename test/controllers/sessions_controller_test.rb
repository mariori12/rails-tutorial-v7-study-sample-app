# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'should get new' do
    get login_path
    assert_response :success
    assert_select 'title', full_title('Log in')
    assert_select 'form[action=?][method=post]', login_path do
      assert_select 'input[name=?][type=email]', 'session[email]'
      assert_select 'input[name=?][type=password]', 'session[password]'
    end
    assert_select 'a[href=?]', signup_path
  end
end
