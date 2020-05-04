class BasePage < SitePrism::Page
  section :content, '#content' do
    element :next_button, 'input[value="Next"]'
    element :select_from_list_error, '.error', text: 'Select a reason or reasons why you are rejecting the evidence'
    element :saved_alert, '.govuk-error-summary', text: 'Your changes have been saved.'
  end
end
