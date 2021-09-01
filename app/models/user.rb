class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :name, :email, :password, :password_confirmation, presence: true
  validates :name, :password,
            length: {minimum: Settings.user.password.min_length}
  validates :email, uniqueness: true, format: {with: VALID_EMAIL_REGEX},
                    length: {maximum: Settings.user.email.max_length}
  has_secure_password
end
