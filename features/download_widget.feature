Feature: Download widget
  In order to demonstrate how to use Commandable
  As a developer
  I want to be able to download the latest source code for Widget from Github
  
  @announce
  Scenario: Git is not installed
    Given Git is not installed
    When I run `commandable widget`
    Then the output should contain "Git is not installed"
  
  
  
