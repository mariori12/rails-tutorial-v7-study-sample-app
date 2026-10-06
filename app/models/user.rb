# frozen_string_literal: true

# User stores account information.
class User < ApplicationRecord
  before_save { email.downcase! }

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, presence: true, length: { minimum: 8 }
  validate :password_byte_length

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  private

  # Rails 7.0 checks character count, but bcrypt limits passwords to 72 bytes.
  def password_byte_length
    limit = ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED
    return if password.nil? || password.bytesize <= limit

    errors.add(:password, :too_long_bytes, count: limit)
  end
end
