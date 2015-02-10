class User < ActiveRecord::Base

  ROLES = %i[admin user]
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise  :database_authenticatable, 
          # :registerable,
          :recoverable, 
          # :rememberable, 
          :trackable, 
          :validatable

  validates_format_of :email, :with => Devise::email_regexp
end
