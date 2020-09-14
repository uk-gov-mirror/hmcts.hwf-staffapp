Given("I have looked up an online application") do
  FactoryBot.create(:online_application, :with_reference, :completed)
  sign_in_with_user
  dashboard_page.look_up_reference(OnlineApplication.last.reference)
end

When("I see the application details") do
  expect(application_details_page.content).to have_header
  expect(application_details_page).to have_text 'Peter Smith'
  expect(application_details_page.content.group[0].input[0].value).to eq '450.0'
  expect(application_details_page.content.group[2].input[0].value).to eq Time.zone.yesterday.day.to_s
  expect(application_details_page.content.group[2].input[1].value).to eq Time.zone.yesterday.month.to_s
  expect(application_details_page.content.group[2].input[2].value).to eq Time.zone.yesterday.year.to_s
  expect(application_details_page.content.group[3].input[0].value).to eq 'ABC123'
end

And("I click next without selecting a jurisdiction") do
  click_button 'Next', visible: false
end

Then("I should see that I must select a jurisdiction error message") do
  expect(application_details_page.content).to have_jurisdiction_error
end

Then("I add a jurisdiction") do
  application_details_page.content.jurisdiction.click
  click_button 'Next', visible: false
end

Then("I should be taken to the check details page") do
  expect(summary_page.content).to have_header
  expect(summary_page).to have_current_path(%r{/online_applications})
end

When("I process the online application") do
  application_details_page.content.jurisdiction.click
  click_button 'Next', visible: false
  complete_processing
end

Then("I see the applicant is not eligible for help with fees") do
  expect(evidence_page.content).to have_not_eligable_header
  expect(evidence_page.content.evidence_summary[0].summary_row[1]).to have_text 'Savings and investments ✓ Passed'
  expect(evidence_page.content.evidence_summary[0].summary_row[2]).to have_text 'Benefits ✗ Failed'
end

And("back to start takes me to the homepage") do
  click_on 'Back to start', visible: false
  expect(page).to have_current_path('/')
end

And("I can see my processed application") do
  expect(dashboard_page.content.last_application[1].text).to have_content 'processed Peter Smith'
end
