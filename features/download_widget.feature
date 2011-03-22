Feature: Download widget
  In order to learn how to use Commandable by looking at a fully functional application
  As a developer
  I want to download the latest source code for Widget from Github

  Background:
    Given Git is installed

  @download_widget
  Scenario: Download widget from github into the default directory
    When I run `commandable widget`
    Then a directory named "widget" should exist 

  @download_widget
  Scenario: Download widget from github into a specified directory
    When I run `commandable widget potato`
    Then a directory named "potato" should exist 
  