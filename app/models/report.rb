# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  # mentioning_reportはactive_mentionを通じてmentioned_reportを参照する
  has_many :active_mentions, class_name: 'Mention', foreign_key: 'mentioning_report_id', inverse_of: :mentioning_report, dependent: :destroy
  has_many :mentioning_reports, through: :active_mentions, source: :mentioned_report

  # mentioning_reportはpassive_mentionを通じてmentioned_reportを参照する
  has_many :passive_mentions, class_name: 'Mention', foreign_key: 'mentioned_report_id', inverse_of: :mentioned_report, dependent: :destroy
  has_many :mentioned_reports, through: :passive_mentions, source: :mentioning_report

  validates :title, presence: true
  validates :content, presence: true

  def editable?(target_user)
    user == target_user
  end

  def created_on
    created_at.to_date
  end

  def extract_mentioned_params
    content.scan(%r{http://localhost:3000/reports/(\d+)}).flatten.uniq
  end

  def save_with_mentions
    ActiveRecord::Base.transaction do
      if save
        add_new_mentions if content.include?('http://localhost:3000/')
        true
      else
        Rails.logger.error('save_with_mentionsで保存に失敗しました')
        false
      end
    end
  end

  def update_with_mentions
    ActiveRecord::Base.transaction do
      if save
        if content.include?('http://localhost:3000/')
          add_new_mentions
          delete_mentions
        end
        true
      else
        Rails.logger.error('update_with_mentionsで保存に失敗しました')
        false
      end
    end
  end

  private

  def add_new_mentions
    mentioned_params = extract_mentioned_params

    mentioned_params.each do |mentioned_param|
      unless Mention.exists?(mentioning_report_id: id, mentioned_report_id: mentioned_param.to_s)
        mention = Mention.new(mentioning_report_id: id, mentioned_report_id: mentioned_param.to_s)
        raise ActiveRecord::Rollback unless mention.save
      end
    end
  end

  def delete_mentions
    mentioned_params = extract_mentioned_params

    active_mentions.each do |mention|
      mention.destroy! unless mentioned_params.include?(mention.mentioned_report_id.to_s)
    end
  end
end
