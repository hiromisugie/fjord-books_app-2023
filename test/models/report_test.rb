# frozen_string_literal: true

require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  test '#created_on' do
    report = Report.new(created_at: '2023-11-22 12:00:00')
    assert_equal 'Wed, 22 Nov 2023', report.created_on.strftime('%a, %d %b %Y')
  end
end
