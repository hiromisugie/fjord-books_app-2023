# frozen_string_literal: true

class ReportsController < ApplicationController
  # GET /reports or /reports.json
  def index
    @reports = Report.order(:id).page(params[:page])
  end

  # GET /reports/1 or /reports/1.json
  def show
    @report = Report.includes(comments: :user).find(params[:id])
  end

  # GET /reports/new
  def new
    @report = Report.new
  end

  # GET /reports/1/edit
  def edit
    @report = current_user.reports.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to '/reports'
  end

  # POST /reports or /reports.json
  def create
    @report = current_user.reports.build(report_params)

    respond_to do |format|
      if @report.save
        format.html { redirect_to report_url(@report), notice: t('controllers.common.notice_create', name: Report.model_name.human) }
        format.json { render :show, status: :created, location: @report }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reports/1 or /reports/1.json
  def update
    @report = current_user.reports.find(params[:id])

    if @report.update(report_params)
      redirect_to @report, notice: t('controllers.common.notice_update', name: Report.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to '/reports'
  end

  # DELETE /reports/1 or /reports/1.json
  def destroy
    @report = current_user.reports.find(params[:id])
    @report.destroy

    redirect_to reports_url, notice: t('controllers.common.notice_destroy', name: Report.model_name.human)
  rescue ActiveRecord::RecordNotFound
    redirect_to '/reports'
  end

  private

  # Only allow a list of trusted parameters through.
  def report_params
    params.require(:report).permit(:title, :content)
  end
end
