require "rack/utils"
require "json"

module ViewHelpers
  def h(value)
    Rack::Utils.escape_html(value.to_s)
  end

  def display_value(value)
    case value
    when nil
      ""
    when String
      value
    when Numeric, TrueClass, FalseClass
      value.to_s
    else
      JSON.generate(value)
    end
  rescue StandardError
    value.to_s
  end
end

