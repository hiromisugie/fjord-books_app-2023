class Books::CommentsController < CommentsController
  before_action :set_commentable, only: %i[create]

  private

  def set_commentable
    @commentable = Book.find(params[:book_id])
  end
end
