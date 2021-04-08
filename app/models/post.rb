class Post < ApplicationRecord
  validates :content, presence: true
  validates :grass_tags,
            :only_followers, presence: false
end