Feature: Ability to create new generators
  In order to make totally awesome new terrains
  As a terrain generation enthusiast
  I should be able to create a new terrain generator
  
  Scenario: Create new terrain generator
    When I visit the new generator page
    And I press "New Generator"
    Then I should be on the generator creation page
    When I press "New Component"
    When I enter name "test generator"
    And I press "Save"
    Then I should be on the generator creation page

