#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

module QuickLauncherTimestamp
  HELP = '用法：ts now、ts 1700000000，或 ts ms 1700000000123。'

  def self.error(message)
    { version: 1, action: 'error', text: message }
  end

  def self.response(request, now: Time.now)
    return error('不支持的请求版本。') unless request.is_a?(Hash) && request['version'] == 1
    return error(HELP) unless request['arguments'].is_a?(String)

    input = request['arguments'].strip
    return { version: 1, action: 'copyAndShow', text: now.to_i.to_s } if input.casecmp('now').zero?

    match = /\A(?:(s|ms)\s+)?([+-]?\d+)\z/i.match(input)
    return error(HELP) unless match

    unit = match[1]&.downcase
    number = match[2]
    digits = number.sub(/\A[+-]/, '').length
    if unit.nil?
      unit = 's' if (1..10).cover?(digits)
      unit = 'ms' if digits == 13
    end
    return error('时间戳位数无法识别；毫秒请使用 ts ms 数字，秒最多 10 位。') if unit.nil?
    return error('秒时间戳最多 10 位，毫秒时间戳最多 13 位。') if digits > (unit == 's' ? 10 : 13)

    value = Integer(number, 10)
    time = unit == 'ms' ? Time.at(Rational(value, 1000)) : Time.at(value)
    formatted = time.getlocal.strftime(unit == 'ms' ? '%Y-%m-%d %H:%M:%S.%L %:z' : '%Y-%m-%d %H:%M:%S %:z')
    { version: 1, action: 'copyAndShow', text: formatted }
  rescue ArgumentError, RangeError
    error('时间戳超出系统支持范围。')
  end
end

if $PROGRAM_NAME == __FILE__
  begin
    request = JSON.parse(STDIN.gets || '')
    result = QuickLauncherTimestamp.response(request)
  rescue JSON::ParserError
    result = QuickLauncherTimestamp.error('请求格式无效。')
  end
  puts JSON.generate(result)
end
