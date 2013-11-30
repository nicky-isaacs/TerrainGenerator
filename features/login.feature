Feature: Ability to log in
  In order to view my generated terrains
  As a user
  I should be able to log in
  
  Scenario: Log in with test user
    When I visit the login screen
    And I enter username "test-user"
    And I enter password "t"
    Then I should be logged in
    
    