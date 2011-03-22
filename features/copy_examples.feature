Feature: Copy Examples
  In order to learn how to use Commandable
  As a developer
  I want to look at some example files

  Scenario: Copy example files from specs into the default directory
    When I run `commandable examples`
    Then a directory named "examples" should exist 
  
  Scenario: Copy example files from specs into a specified directory
    When I run `commandable examples shazam`
    Then a directory named "shazam" should exist 
  
