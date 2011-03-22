Around('@download_widget') do |scenario, block|
  Timeout.timeout(30) do
    block.call
  end
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