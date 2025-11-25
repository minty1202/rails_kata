# typed: true

class SafeCaseNotesController < ApplicationController
  extend T::Sig
  def index
    @notes = Note.all
    render json: @notes
  end

  def create
    @note = Note.safe_new(
      title: note_params.title,
      content: note_params.content
    )

    if @note.save
      render json: @note, status: :created
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  private

  sig { returns(NoteParamsObject) }
  def note_params
    NoteParamsObject.from_params(params)
  end
end
