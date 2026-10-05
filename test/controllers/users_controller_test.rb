# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'should show user profile' do
    user = User.create!(name: 'Example User', email: 'user@example.com',
                        password: 'password', password_confirmation: 'password')
    get user_path(user)
    assert_response :success
    assert_select 'title', full_title(user.name)
    assert_select 'h1', text: user.name
    assert_select 'img.gravatar[alt=?]', user.name
    assert_select '.debug_dump', count: 0
  end

  test 'should get new' do
    get signup_path
    assert_response :success
    assert_select 'form[action=?][method=post]', users_path do
      assert_select 'input[name=?][type=text]', 'user[name]'
      assert_select 'input[name=?][type=email]', 'user[email]'
      assert_select 'input[name=?][type=password]', 'user[password]'
      assert_select 'input[name=?][type=password]', 'user[password_confirmation]'
      assert_select 'input[type=submit][value=?]', 'Create my account'
    end
  end
end
