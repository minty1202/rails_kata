# typed: true

class NotesController < ApplicationController
  extend T::Sig
  def index
    @notes = Note.all
    render json: @notes
  end

  def create
    @note = Note.new(**note_params)

    if @note.save
      render json: @note, status: :created
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  private

  def note_params
    params.require(:note).permit(:title, :content)
  end
end
