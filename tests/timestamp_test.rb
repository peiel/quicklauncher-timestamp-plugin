# frozen_string_literal: true

require 'minitest/autorun'
require 'open3'
require_relative '../main'

class TimestampTest < Minitest::Test
  def setup
    @old_tz = ENV['TZ']
    ENV['TZ'] = 'UTC'
  end

  def teardown
    ENV['TZ'] = @old_tz
  end

  def result(text)
    QuickLauncherTimestamp.response('version' => 1, 'arguments' => text)
  end

  def test_seconds_milliseconds_explicit_units_and_negative
    assert_equal '2023-11-14 22:13:20 +00:00', result('1700000000')[:text]
    assert_equal '2023-11-14 22:13:20.123 +00:00', result('1700000000123')[:text]
    assert_equal '1970-01-01 00:00:01.000 +00:00', result('ms 1000')[:text]
    assert_equal '1969-12-31 23:59:59 +00:00', result('s -1')[:text]
    assert_equal '1969-12-31 23:59:59.999 +00:00', result('ms -1')[:text]
    assert_equal '2286-11-20 17:46:39 +00:00', result('s 9999999999')[:text]
  end

  def test_local_time_zone_and_now
    ENV['TZ'] = 'Asia/Shanghai'
    assert_equal '2023-11-15 06:13:20 +08:00', result('1700000000')[:text]
    expected = { version: 1, action: 'copyAndShow', text: '1700000000' }
    assert_equal expected, QuickLauncherTimestamp.response({ 'version' => 1, 'arguments' => 'NOW' }, now: Time.at(1_700_000_000))
  end

  def test_invalid_inputs_are_errors
    ['', '12345678901', '123456789012', 's 10000000000', 'ms 10000000000000', '1.5', '2023-11-14', '1;echo x', 's 1 2'].each do |input|
      assert_equal 'error', result(input)[:action], input
    end
    assert_equal 'error', QuickLauncherTimestamp.response('version' => 2, 'arguments' => '1')[:action]
    assert_equal 'error', QuickLauncherTimestamp.response('version' => 1, 'arguments' => nil)[:action]
  end

  def test_stdio_protocol
    out, err, status = Open3.capture3('ruby', File.expand_path('../main.rb', __dir__), stdin_data: '{"version":1,"arguments":"1700000000"}')
    assert status.success?
    assert_empty err
    assert_equal({ 'version' => 1, 'action' => 'copyAndShow', 'text' => '2023-11-14 22:13:20 +00:00' }, JSON.parse(out))
  end
end
