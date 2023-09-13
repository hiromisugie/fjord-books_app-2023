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
        add_new_mentions if @report.content.include?('http://localhost:3000/')
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
          add_new_mentions
          delete_mentions
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

  def add_new_mentions
    mentioned_params = @report.content.scan(%r{http://localhost:3000/reports/(\d+)}).flatten.uniq

    mentioned_params.each do |mentioned_param|
      unless Mention.exists?(mentioning_report_id: @report.id, mentioned_report_id: mentioned_param.to_s)
        @mention = Mention.new(mentioning_report_id: @report.id, mentioned_report_id: mentioned_param.to_s)
        @mention.save
      end
    end
  end

  def delete_mentions
    mentioned_params = @report.content.scan(%r{http://localhost:3000/reports/(\d+)}).flatten.uniq

    @report.mentioning_reports.each do |mentioning_report|
      @report.mentioning_reports.delete(mentioning_report) unless mentioned_params.include?(mentioning_report.id.to_s)
    end
  end
end
