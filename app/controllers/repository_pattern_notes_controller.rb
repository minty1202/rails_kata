# typed: true

class RepositoryPatternNotesController < ApplicationController
  extend T::Sig

  sig { void }
  def index
    # repository を作成してリポジトリにアクセス
    @notes = repo.notes.all
    render json: @notes
  end

  sig { void }
  def create
    # repository 経由でリポジトリを使って作成
    @note = repo.notes.create(
      title: note_params.title,
      content: note_params.content
    )

    if @note.persisted?
      render json: @note, status: :created
    else
      render json: { errors: @note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # 本来は ApplicationController などにおいて、シングルトン化するのが望ましいですが、例としてここにおいています。
  sig { returns(ApplicationRepository) }
  def repo
    @repo ||= T.let(ApplicationRepository.new, T.nilable(ApplicationRepository))
  end

  sig { returns(NoteParamsObject) }
  def note_params
    NoteParamsObject.from_params(params)
  end
end
