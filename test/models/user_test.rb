# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: 'Example User', email: 'user@example.com',
                     password: 'password', password_confirmation: 'password')
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'name should be present' do
    @user.name = ' ' * 6
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = ' ' * 6
    assert_not @user.valid?
  end

  test 'name should not be too long' do
    @user.name = 'a' * 51
    assert_not @user.valid?
  end

  test 'email should not be too long' do
    @user.email = "#{'a' * 244}@example.com"
    assert_not @user.valid?
  end

  test 'maximum length name and email should be valid' do
    @user.name = 'a' * 50
    @user.email = "#{'a' * 243}@example.com"
    assert @user.valid?
  end

  test 'email validation should accept valid addresses' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |address|
      @user.email = address
      assert @user.valid?, "#{address.inspect} should be valid"
    end
  end

  test 'email validation should reject invalid addresses' do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |address|
      @user.email = address
      assert_not @user.valid?, "#{address.inspect} should be invalid"
    end
  end

  test 'email addresses should be unique regardless of case' do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save!
    assert_not duplicate_user.valid?
  end

  test 'email addresses should be saved as lowercase' do
    mixed_case_email = 'Foo@ExAMPle.CoM'
    @user.email = mixed_case_email
    @user.save!
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test 'database should reject duplicate email addresses' do
    @user.save!
    duplicate_user = @user.dup
    assert_raises ActiveRecord::RecordNotUnique do
      duplicate_user.save!(validate: false)
    end
  end

  test 'password should be present' do
    @user.password = @user.password_confirmation = nil
    assert_not @user.valid?
  end

  test 'password should not be blank' do
    @user.password = @user.password_confirmation = ' ' * 8
    assert_not @user.valid?
  end

  test 'password should have a minimum length of eight characters' do
    @user.password = @user.password_confirmation = 'a' * 7
    assert_not @user.valid?
  end

  test 'eight character password should be valid' do
    @user.password = @user.password_confirmation = 'a' * 8
    assert @user.valid?
  end

  test 'password confirmation should match' do
    @user.password_confirmation = 'different'
    assert_not @user.valid?
  end

  test 'password should not exceed bcrypt byte limit' do
    @user.password = @user.password_confirmation = 'a' * 73
    assert_not @user.valid?
    @user.password = @user.password_confirmation = 'あ' * 25
    assert_not @user.valid?
    @user.password = @user.password_confirmation = 'a' * 72
    assert @user.valid?
    @user.password = @user.password_confirmation = 'あ' * 24
    assert @user.valid?
  end

  test 'saved user should authenticate with the correct password' do
    @user.save!
    saved_user = User.find(@user.id)
    assert_nil saved_user.password
    assert_not_equal 'password', saved_user.password_digest
    assert_equal saved_user, saved_user.authenticate('password')
    assert_equal false, saved_user.authenticate('incorrect')
  end
end
