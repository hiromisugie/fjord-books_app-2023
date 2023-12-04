# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  test '#editable?' do
    user = User.new
    assert Report.new(user: user).editable?(user)
  end

  test '#created_on' do
    report = Report.new(created_at: '2023-11-22 12:00:00')
    assert_equal 'Wed, 22 Nov 2023', report.created_on.strftime('%a, %d %b %Y')
  end

  test '#save_with_mentions' do
    mentioned_report = Report.create!(title: 'メンションされる日報', content: '内容', user_id: users(:alice).id)
    mentioning_report = Report.new(title: 'メンションする日報', content: "http://localhost:3000/reports/#{mentioned_report.id}", user_id: users(:bob).id)
    mentioning_report.save_with_mentions

    assert_equal 1, mentioning_report.mentioning_reports.count
  end
end
