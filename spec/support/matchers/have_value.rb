RSpec::Matchers.define :have_value do |expected|
  match do |actual|
    actual.respond_to?(:to_value) && actual.to_value == expected
  end

  failure_message_for_should do |actual|
    "Expected that #{actual.class}(text value: #{actual.text_value}, value: #{actual.to_value}) should have value #{expected}"
  end

  failure_message_for_should_not do |actual|
    "Expected that #{actual.class}(text value: #{actual.text_value}, value: #{actual.to_value}) should not have value #{expected}"
  end

  description do
    "have the value #{expected}"
  end
end

