# typed: true

class ServiceNotesController < ApplicationController
  extend T::Sig

  sig { void }
  def index
    @notes = Note.all
    render json: @notes
  end

  sig { void }
  def create
    # Form 層: バリデーション
    form = NoteForm.from_params_object(note_params)

    unless form.valid?
      render json: { errors: form.errors }, status: :unprocessable_entity
      return
    end

    # Service 層: ビジネスロジック
    @note = CreateNoteService.call(form)

    if @note.persisted?
      render json: @note, status: :created
    else
      render json: { errors: @note.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # Params Object 層: パラメータの型安全な抽出
  sig { returns(NoteParamsObject) }
  def note_params
    NoteParamsObject.from_params(params)
  end
end
