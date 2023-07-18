class Reports::CommentsController < CommentsController
  before_action :set_commentable, only: %i[create destroy]

  private

  def set_commentable
    @commentable = Report.find(params[:report_id])
  end
end
