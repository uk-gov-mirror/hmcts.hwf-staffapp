@api
Feature: Test for Disposable Capital

  Background:
    Given I am a valid api user
    And I am single

  Scenario Outline: Test for disposable capital
    Given the court or tribunal fee is <Court Fee>
    And the age is <Age>
    And the savings and investment amount is <Capital>
    When I request a calculation
    Then the response should have only messages with keys <Message Key 1> and <Message Key 2>
    And the response should suggest the likelyhood of getting help as <Likelyhood>
    And the response should contain a savings and investment amount of <Capital> in the previous answers
    And the response should request that the "benefits" question is the next question to be answered
    Examples:
      | Age | Court Fee | Capital | Message Key 1      | Message Key 2                  | Likelyhood |
      | 60  | 100       | 2999    | likely_help_fees   | likely_help_fees_explanation   | likely     |
      | 59  | 999       | 4000    | unlikely_help_fees | unlikely_help_fees_explanation | unlikely   |
      | 50  | 1000      | 5000    | unlikely_help_fees | unlikely_help_fees_explanation | unlikely   |
      | 40  | 1001      | 6000    | unlikely_help_fees | unlikely_help_fees_explanation | unlikely   |