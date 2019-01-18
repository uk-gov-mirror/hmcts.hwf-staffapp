Given("I have started an application") do
  start_application
end

And("I am on the personal details part of the application") do
  expect(current_path).to eq '/applications/2/personal_informations'
  expect(personal_details_page.content).to have_header
end

When("I successfully submit my required personal details") do
  personal_details_page.submit_required_information
end

Then("I should be taken to the application details page") do
  expect(current_path).to eq '/applications/2/details'
  expect(application_details_page.content).to have_header
end