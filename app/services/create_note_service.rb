# typed: strict

class CreateNoteService
  extend T::Sig

  private :new

  # Form から作成
  sig { params(form: NoteForm).returns(Note) }
  def self.call(form)
    new(form).call
  end

  sig { params(form: NoteForm).void }
  def initialize(form)
    @form = form
  end

  sig { returns(Note) }
  def call
    attrs = @form.attributes

    Note.create(
      title: attrs[:title],
      content: attrs[:content]
    )
  end
end
