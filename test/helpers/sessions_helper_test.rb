# frozen_string_literal: true

require 'test_helper'

class SessionsHelperTest < ActiveSupport::TestCase
  def setup
    @helper = Object.new.extend(SessionsHelper)
    @helper.define_singleton_method(:session) { @session ||= {} }
    @helper.define_singleton_method(:reset_session) { @session = {} }
  end

  test 'missing or deleted user is not logged in' do
    assert_nil @helper.current_user
    assert_not @helper.logged_in?
    @helper.session[:user_id] = -1
    assert_nil @helper.current_user
    assert_not @helper.logged_in?
  end

  test 'current user is memoized within a request' do
    @helper.session[:user_id] = users(:michael).id
    user = @helper.current_user
    assert_equal users(:michael), user
    assert_same user, @helper.current_user
    assert @helper.logged_in?
  end

  test 'logout clears the session and memoized user' do
    @helper.log_in(users(:michael))
    @helper.session[:other_data] = 'value'
    assert @helper.logged_in?

    @helper.log_out

    assert_empty @helper.session
    assert_nil @helper.instance_variable_get(:@current_user)
    assert_nil @helper.current_user
    assert_not @helper.logged_in?
  end
end
