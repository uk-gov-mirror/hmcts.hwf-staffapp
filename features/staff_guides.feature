Feature: Staff guides

  Background: Navigate to staff guides
    Given I am on the Help with Fees staff application home page

    Scenario: How to guide
      And I am signed in on the guide page
      When I click on how to guide
      But I am not within the network or connected to vpn
      Then I should see you are accessing the intranet from outside the MoJ network

    Scenario: Key control checks
      And I am signed in on the guide page
      When I click on key control checks
      But I am not within the network or connected to vpn
      Then I should see you are accessing the intranet from outside the MoJ network

    Scenario: Staff guidance
      And I am signed in on the guide page
      When I click on staff guidance
      But I am not within the network or connected to vpn
      Then I should see you are accessing the intranet from outside the MoJ network
    
    Scenario: Process application
      And I am signed in on the guide page
      When I click on process application
      Then I should be taken to the process application page

    Scenario: Evidance checks
      And I am signed in on the guide page
      When I click on evidance checks
      Then I should be taken to the evidance checks page

    Scenario: Part-payments
      And I am signed in on the guide page
      When I click on part-payments
      Then I should be taken to the part-payments page
    
    Scenario: Appeals
      And I am signed in on the guide page
      When I click on appeals
      Then I should be taken to the appeals page
    
    Scenario: Fraud awareness
      And I am signed in on the guide page
      When I click on fraud awareness
      But I am not within the network or connected to vpn
      Then I should see you are accessing the intranet from outside the MoJ network

    Scenario: Suspected fraud
      And I am signed in on the guide page
      When I click on suspected fraud
      Then I should be taken to the suspected fraud page
