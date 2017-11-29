Feature: Test for Disposable Capital

  Background:
    Given I am an api user
    And I am single
    And I am under 61 years old
    And fee band is up to and including £1000 with a disposable capital less than £3000

  Scenario Outline: Test for disposable capital
    Given the court or tribunal fee is <Court Fee>
    And the savings and investment amount is <Capital>
    When I request a calculation
    Then the response should have only messages with keys <Message Key 1> and <Message Key 2>
    And the response should suggest the likelyhood of getting help as <Likelyhood>
    And the response should contain a savings and investment amount of <Capital> in the previous answers
    And the response should request that the "benefits" question is the next question to be answered
    Examples:
      | Court Fee | Capital | Message Key 1      | Message Key 2                  | Likelyhood |
      | 100       | 3000    | likely_help_fees   | likely_help_fees_explanation   | likely     |
      | 999       | 4000    | unlikely_help_fees | unlikely_help_fees_explanation | unlikely   |
      | 1000      | 5000    | unlikely_help_fees | unlikely_help_fees_explanation | unlikely   |
      | 1001      | 6000    | unlikely_help_fees | unlikely_help_fees_explanation | unlikely   |