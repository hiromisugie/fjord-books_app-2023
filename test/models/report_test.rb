# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  test '#editable?' do
    alice = User.new
    bob = User.new
    assert Report.new(user: alice).editable?(alice)
    assert_not Report.new(user: alice).editable?(bob)
  end

  test '#created_on' do
    report = Report.new(created_at: '2023-11-22 12:00:00')
    assert_equal 'Wed, 22 Nov 2023', report.created_on.strftime('%a, %d %b %Y')
    assert_not_equal 'Thu, 23 Nov 2023', report.created_on.strftime('%a, %d %b %Y')
  end

  test '#save_with_mentions' do
    mentioned_report = Report.create!(title: 'メンションされる日報', content: '内容', user_id: users(:alice).id)
    mentioning_report = Report.new(title: 'メンションする日報', content: '初めはメンション無し', user_id: users(:bob).id)

    # メンションがない状態で保存
    mentioning_report.save_with_mentions
    assert_equal 0, mentioning_report.mentioning_reports.count

    # メンションを追加して保存
    mentioning_report.content = "メンションを追加： http://localhost:3000/reports/#{mentioned_report.id}"
    mentioning_report.save_with_mentions
    assert_equal 1, mentioning_report.mentioning_reports.count

    # メンションを削除して保存
    mentioning_report.content = 'メンションを削除'
    mentioning_report.save_with_mentions
    assert_equal 0, mentioning_report.mentioning_reports.count
  end
end
