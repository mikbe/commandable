Before do
  @git = `which git`
end

When /^I run cucumber$/ do
  # These are just to see color output is working
end

Then /^it doesn't give an error$/ do
  # These are just to see color output is working
end

Given /^Git is not installed$/ do
  FileUtils.mv(@git, "#{@git}.fake") if File.exist?("#{@git}.fake")
end


After do
  FileUtils.mv( "#{@git}.fake", @git) if File.exist?("#{@git}.fake")
end