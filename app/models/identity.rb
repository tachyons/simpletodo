class Identity < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user

  def self.find_with_omniauth(auth)
    where(uid: auth['uid'], provider: auth['provider']).first
  end

  def self.create_with_omniauth(auth)
    create(uid: auth['uid'], provider: auth['provider'])
  end
end
