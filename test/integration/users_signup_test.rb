# frozen_string_literal: true

require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test 'invalid signup information' do
    get signup_path
    assert_select '#error_explanation', count: 0
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: '', email: 'user@invalid',
                                        password: 'foo', password_confirmation: 'bar' } }
    end
    assert_response :unprocessable_entity
    assert_select 'title', full_title('Sign up')
    assert_select 'div#error_explanation' do
      assert_select 'div.alert.alert-danger', text: 'The form contains 4 errors.'
      assert_select 'li', count: 4
    end
    assert_select '.field_with_errors input[name=?]', 'user[email]'
    assert_select 'input[name=?][value=?]', 'user[email]', 'user@invalid'
    assert_select 'input[type=password][value]', count: 0
  end

  test 'blank password displays five validation errors' do
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: '', email: 'user@invalid',
                                        password: '', password_confirmation: '' } }
    end
    assert_response :unprocessable_entity
    assert_select '#error_explanation li', count: 5
  end

  test 'signup does not assign unpermitted attributes' do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: 'Example User', email: 'user@example.com',
                                        password: 'password', password_confirmation: 'password',
                                        id: 123456, created_at: '2000-01-01', admin: '1' } }
    end
    user = User.find_by!(email: 'user@example.com')
    assert_not_equal 123456, user.id
    assert_not_equal 2000, user.created_at.year
    assert_redirected_to user
  end
end
