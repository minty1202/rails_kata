# typed: strict

class NoteForm < T::Struct
  include ActiveModel::Validations

  extend T::Sig

  const :title, String
  const :content, T.nilable(String)

  validates :title, presence: true, length: { maximum: 255 }

  # NoteParamsObject から作成
  sig { params(params_obj: NoteParamsObject).returns(NoteForm) }
  def self.from_params_object(params_obj)
    new(
      title: params_obj.title,
      content: params_obj.content
    )
  end

  # 正規化された属性を返す（Service で使用する用）
  sig { returns({ title: String, content: T.nilable(String) }) }
  def attributes
    {
      title: title.strip,
      content: content&.strip
    }
  end
end
