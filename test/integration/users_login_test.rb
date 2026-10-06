# frozen_string_literal: true

require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'login with valid email and invalid password' do
    post login_path, params: { session: { email: @user.email, password: 'invalid' } }
    assert_not is_logged_in?
    assert_response :unprocessable_entity
    assert_select 'title', full_title('Log in')
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test 'login with valid information' do
    get login_path
    previous_session_id = session.id.to_s
    post login_path, params: { session: { email: @user.email.upcase, password: 'password' } }
    assert is_logged_in?
    assert_equal @user.id, session[:user_id]
    assert_not_equal previous_session_id, session.id.to_s
    assert_response :see_other
    assert_redirected_to @user
    cookie = response.headers['Set-Cookie'].to_s
    assert_includes cookie.downcase, 'httponly'
    assert_no_match(/expires=/i, cookie)
    follow_redirect!
    assert_response :success
    assert_select 'title', full_title(@user.name)
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?][data-turbo-method=delete]', logout_path
    assert_select 'a[href=?]', user_path(@user)

    cookies.delete(Rails.application.config.session_options[:key])
    get root_path
    assert_not is_logged_in?
    assert_select 'a[href=?]', login_path
    assert_select '#account', count: 0
  end

  test 'login with invalid information' do
    get login_path
    assert_response :success
    post login_path, params: { session: { email: '', password: '' } }
    assert_response :unprocessable_entity
    assert_not is_logged_in?
    assert_select 'title', full_title('Log in')
    assert_not flash.empty?
    assert_select '.alert.alert-danger', text: 'Invalid email/password combination'
    get root_path
    assert flash.empty?
    assert_select '.alert.alert-danger', count: 0
  end
end
