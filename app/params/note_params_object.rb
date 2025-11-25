# typed: strict

class NoteParamsObject < T::Struct
  const :title, String
  const :content, T.nilable(String)

  extend T::Sig

  # ActionController::Parameters から型安全に変換
  sig { params(params: ActionController::Parameters).returns(NoteParamsObject) }
  def self.from_params(params)
    note_params = params.require(:note).permit(:title, :content)

    new(
      title: T.cast(note_params[:title], String),
      content: T.let(note_params[:content], T.nilable(String))
    )
  end
end
