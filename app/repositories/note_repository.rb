# typed: strict

class NoteRepository
  extend T::Sig

  # 新規作成（バリデーションエラーでも例外を出さない）
  sig { params(title: String, content: T.nilable(String)).returns(Note) }
  def create(title:, content:)
    Note.create(title: title, content: content)
  end

  # 新規作成（バリデーションエラーで例外を出す）
  sig { params(title: String, content: T.nilable(String)).returns(Note) }
  def create!(title:, content:)
    Note.create!(title: title, content: content)
  end

  # 全件取得
  sig { returns(T::Array[Note]) }
  def all
    Note.all.to_a
  end
end
