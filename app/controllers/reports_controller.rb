# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_report, only: %i[edit update destroy]

  def index
    @reports = Report.includes(:user).order(id: :desc).page(params[:page])
  end

  def show
    @report = Report.find(params[:id])
    @mentioned_reports = @report.mentioned_reports.order(updated_at: :desc).order(id: :desc).includes(:user)
  end

  # GET /reports/new
  def new
    @report = current_user.reports.new
  end

  def edit; end

  def create
    ActiveRecord::Base.transaction do
      @report = current_user.reports.new(report_params)

      if @report.save
        @report.add_new_mentions if @report.content.include?('http://localhost:3000/')
        redirect_to @report, notice: t('controllers.common.notice_create', name: Report.model_name.human)
      else
        flash.now[:notice] = 'mentionの保存に失敗したので、作成できませんでした。'
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  def update
    ActiveRecord::Base.transaction do
      if @report.update(report_params)
        if @report.content.include?('http://localhost:3000')
          @report.add_new_mentions
          @report.delete_mentions
        else
          @report.mentioning_reports.clear
        end
        redirect_to @report, notice: t('controllers.common.notice_update', name: Report.model_name.human)
      else
        flash.now[:notice] = 'mentionの保存に失敗したので、更新できませんでした。'
        render :edit, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  end

  def destroy
    @report.destroy

    redirect_to reports_url, notice: t('controllers.common.notice_destroy', name: Report.model_name.human)
  end

  private

  def set_report
    @report = current_user.reports.find(params[:id])
  end

  def report_params
    params.require(:report).permit(:title, :content)
  end

end
