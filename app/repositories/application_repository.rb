# typed: strict

class ApplicationRepository
  extend T::Sig

  sig { void }
  def initialize
    @note_repository = T.let(NoteRepository.new, NoteRepository)
  end

  # notes リポジトリへのアクセサ
  sig { returns(NoteRepository) }
  def notes
    @note_repository
  end
end
