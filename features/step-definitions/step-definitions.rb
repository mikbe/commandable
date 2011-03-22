Before do
  @aruba_timeout_seconds = 30
end

When /^I run cucumber$/ do
  # These are just to see color output is working
end

Then /^it doesn't give an error$/ do
  # These are just to see color output is working
end

Given /^Git is installed$/ do
  raise Exception, "\n#{"ATTENION! " * 5}\nYou need git installed to run the Cucumber tests!\n\n" if `which git`.empty?
end