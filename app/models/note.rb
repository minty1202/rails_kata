# typed: true

class Note < ApplicationRecord
  extend T::Sig

  validates :title, presence: true

  sig { params(title: String, content: T.nilable(String)).returns(Note) }
  def self.safe_new(title:, content: nil)
    Note.new(title: title, content: content)
  end
end
