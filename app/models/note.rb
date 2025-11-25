# typed: true

class Note < ApplicationRecord
  extend T::Sig

  validates :title, presence: true
end
