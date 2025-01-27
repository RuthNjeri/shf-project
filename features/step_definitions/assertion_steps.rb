module PathHelpers
  # remove any leading locale path info
  def current_path_without_locale(path)
    locale_pattern =  /^(\/)(en|sv)?(\/)?(.*)$/
    path.gsub(locale_pattern, '\1\4')
  end

  def get_path(pagename, user = @user)
    case pagename.downcase
      when  'login'
        path = new_user_session_path
      when 'landing'
        path = root_path
      when 'new application'
        path = new_shf_application_path
      when 'edit application', 'edit my application'
        user.reload
        path = edit_shf_application_path(user.shf_application)
      when 'application', 'show my application'
        path = shf_application_path(user.shf_application)
      when 'user instructions'
        path = information_path
      when 'member instructions'
        path = information_path
      when 'all waiting for info reasons'
        path = admin_only_member_app_waiting_reasons_path
      when 'new waiting for info reason'
        path = new_admin_only_member_app_waiting_reason_path
      when 'register as a new user'
        path = new_user_registration_path
      when 'edit registration for a user'
        path = edit_user_registration_path
      when 'new password'
        path = new_user_password_path
      when 'all member app waiting reasons'
        path = admin_only_member_app_waiting_reasons_path
      when 'business categories'
        path = business_categories_path
      when 'membership applications', 'shf applications'
        path = shf_applications_path
      when 'all companies'
        path = companies_path
      when 'create a new company'
        path = new_company_path
      when 'submit new membership application'
        path = new_shf_application_path
      when 'my first company'
        path = company_path(user.shf_application.companies.first)
      when 'my second company'
        path = company_path(user.shf_application.companies.second)
      when 'my third company'
        path = company_path(user.shf_application.companies.third)
      when 'edit my company'
        path = edit_company_path(user.shf_application.companies.first)
      when 'all users'
        path = users_path
      when 'all shf documents'
        path = shf_documents_path
      when 'new shf document'
        path = new_shf_document_path
      when 'user details', 'user profile'
        path = user_path(user)
      when 'test exception notifications'
        path = test_exception_notifications_path
      when 'admin dashboard'
        path = admin_only_dashboard_path
      when 'admin edit app configuration'
        path = admin_only_edit_app_configuration_path
      when 'admin show app configuration'
        path = admin_only_app_configuration_path
    end

    expect(path).not_to be_empty, "A step was called with path= '#{pagename}', but that path is not defined in #{__method__} \n    (which is in #{__FILE__}"

    path
  end
end

World(PathHelpers)

Then "I should{negate} see {capture_string}" do |negate, content|
  begin
    expect(page).send (negate ? :not_to : :to), have_content(/#{content}/i)
  rescue RSpec::Expectations::ExpectationNotMetError
    expect(page).send (negate ? :not_to : :to), have_content(content)
  end
end


Then "I should see raw HTML {capture_string}" do |html|
  expect(page.body).to match html
end

Then "I should see {capture_string} or {capture_string} in the raw HTML" do | str1, str2 |
  expect(page.body).to (match(str1).or match(str2))
end

Then "I should{negate} see {capture_string} image" do |negate, alt_text|
  expect(page).send (negate ? :not_to : :to),  have_xpath("//img[contains(@alt,'#{alt_text}')]")
end


Then "I should{negate} see button {capture_string}" do |negate, button|
  expect(page).send (negate ? :not_to : :to),  have_button(button)
end


Then "I should{negate} see {capture_string} link" do |negate, link_label|
  expect(page).send (negate ? :not_to : :to),  have_link(link_label)
end


Then(/^I should( not)? see the (?:checkbox|radio button) with id "([^"]*)" checked$/) do |negate, checkbox_id|
#  expect(page).send (negate ? :not_to : :to),  have_checked_field(checkbox_id)
 expect(page).to have_selector(:id, checkbox_id), "got: #{page.html}"
end


Then(/^I should( not)? see the (?:checkbox|radio button) with id "([^"]*)" unchecked$/) do |negate, checkbox_id|
  expect(page).send (negate ? :not_to : :to),  have_unchecked_field(checkbox_id)
end


Then(/^I should be on (?:the )*"([^"]*)" page(?: for "([^"]*)")?$/) do |page, email|
  user = email == nil ? @user :  User.find_by(email: email)
  expect(current_path_without_locale(current_path)).to eq get_path(page, user)
end


Then(/^I should see:$/) do |table|
  table.hashes.each do |hash|
    expect(page).to have_content hash[:content]
  end
end


Then "I should{negate} see {capture_string} in the row for {capture_string}" do |negate, text, row_identifier|
  row = find(:xpath, "//tr[td//text()[contains(.,'#{row_identifier}')]]")
  expect(row).send (negate ? :not_to : :to), have_content(text)
end


Then "I should{negate} see {capture_string} in the div with id {capture_string}" do | negate, expected_text, div_id |
  div = page.find(:id, div_id)
  expect(div).send (negate ? :not_to : :to), have_content(expected_text)
end


Then "I should{negate} see {capture_string} {digits} time(?:s) in the div with id {capture_string}" do | negate, expected_text, num_times, div_id |
  div = page.find(:id, div_id)
  expect(div).send (negate ? :not_to : :to), have_content(expected_text, count: num_times)
end


Then(/^I should see "([^"]*)" applications$/) do |number|
  expect(page).to have_selector('tr.applicant', count: number)
end


Then(/^I should see "([^"]*)" companies/) do |number|
  expect(page).to have_selector('tr.company', count: number)
end


Then(/^I should see "([^"]*)" business categories/) do |number|
  expect(page).to have_selector('tr.business_category', count: number)
end

Then(/^I should see "([^"]*)" address(?:es)?/) do |number|
  expect(page).to have_selector('tr.address', count: number)
end

Then(/^I should see "([^"]*)" event(?:s)?/) do |number|
  expect(page).to have_selector('tr.event', count: number)
end


Then "the field {capture_string} should{negate} have a required field indicator" do |label_text, negate|
  expect(page).send ( negate ? :not_to : :to), have_xpath("//label[@class='required'][text()='#{label_text}']")
end


Then(/^I should see (\d+) (.*?) rows$/) do |n, css_class_name|
  n = n.to_i
  expect(page).to have_selector(".#{css_class_name}", count: n)
  expect(page).not_to have_selector(".#{css_class_name}", count: n+1)
end

Then(/^I should see at least one column with class "([^"]*)"/) do | css_class_name |
  expect(page).to  have_xpath("//td[@class='#{css_class_name}']")
end

Then "I should see error {capture_string} {capture_string}" do |model_attribute, error|
  expect(page).to have_content("#{model_attribute} #{error}")
end


Then "I should see status line with status {capture_string} and date {capture_string}" do |status, date_string|
  expect(page).to have_content("#{status} - #{date_string}")
end


Then "I should{negate} see status line with status {capture_string}" do |negate, status|
  expect(page).send (negate ? :not_to : :to), have_content("#{status} - ")
end


Then "I should see {digits} {capture_string}" do |n, content |
  n = n.to_i
  expect(page).to have_text("#{content}", count: n)
  expect(page).not_to have_text("#{content}", count: n+1)
end

Then "{capture_string} should{negate} be visible" do |string, negate|
  expect(has_text?(:visible, "#{string}")).to be negate == nil
end


# Tests that an input has a given value
Then "the {capture_string} field should be set to {capture_string}" do |field, text_value|
  expect(find_field(field).value).to eq(text_value)
end


Then(/^I should see link "([^"]*)" with target = "([^"]*)"$/) do |link_identifier, target_value|
  expect(find_link(link_identifier)[:target]).to eq(target_value)
end


Then "I should see flash text {capture_string}" do | text |
  expect(page).to have_selector('#flashes', text: text )
end

Then "I should{negate} see {capture_string} in the row for user {capture_string}" do | negate, expected_text, user_email |
  td = page.find(:css, 'td', text: user_email) # find the td with text = user_email
  tr = td.find(:xpath, './parent::tr') # get the parent tr of the td
  expect(tr.text).send (negate ? :not_to : :to), match(Regexp.new(expected_text))
end


Then "I should{negate} see the checkbox with id {capture_string} {checked} in the row for user {capture_string}" do | negate_see_it, checkbox_id, checked, user_email  |
  td = page.find(:css, 'td', text: user_email)  # find the td with text = user_email
  tr = td.find(:xpath, './parent::tr') # get the parent tr of the td

  expect(tr).send (negate_see_it ? :not_to : :to), have_selector(:id, checkbox_id)
  #checkbox = tr.find(:xpath, '//td[descendant::input[@id="date_membership_packet_sent"]]')

  unless negate_see_it
    case checked
    when 'checked'
      expect(tr).to have_checked_field(checkbox_id)
    when 'unchecked'
      expect(tr).to have_unchecked_field(checkbox_id)
    end
  end

end


Then "I should{negate} see {capture_string} for class {capture_string} in the row for user {capture_string}" do |negate, expected_text, css_class, user_email |
  td = page.find(:css, 'td', text: user_email) # find the td with text = user_email
  tr = td.find(:xpath, './parent::tr') # get the parent tr of the td
  expect(tr).send (negate ? :not_to : :to), have_css(".#{css_class}", text: expected_text)
end


Then(/^I should( not)? see xpath "([^"]*)"$/) do | negate, xp |
  expect(page).send (negate ? :not_to : :to),  have_xpath(xp)
end


Then(/^I should( not)? see "([^"]*)" before "([^"]*)"$/) do |not_see, toSearch, last|
  assert_text toSearch
  regex = /#{Regexp.quote("#{toSearch}")}.+#{Regexp.quote("#{last}")}/m

  if not_see
    assert_no_text :visible, regex
  else
    assert_text :visible, regex
  end
end


Then(/^I should be on the SHF document page for "([^"]*)"$/)  do | doc_title |
  shf_doc = ShfDocument.find_by_title(doc_title)
  expect(current_path_without_locale(current_path)).to eq shf_document_path(shf_doc)
end


Then(/^all addresses for the company named "([^"]*)" should( not)? be geocoded$/) do | company_name, no_geocode |

  co = Company.find_by_name(company_name)
  if no_geocode
    expect( co.addresses.reject(&:geocoded? ).count).not_to be 0
  else
    expect( co.addresses.reject(&:geocoded? ).count).to be 0
  end

end


# Checks that a certain option is selected for a text field (from https://github.com/makandra/spreewald)
Then "{capture_string} should{negate} have {capture_string} selected" do | select_list, negate, expected_string |

  try_again = true

  begin
    field = find_field(select_list)

    field_value = case field.tag_name
                    when 'select'
                      options = field.all('option')
                      selected_option = options.detect(&:selected?) || options.first
                      if selected_option && selected_option.text.present?
                        selected_option.text.strip
                      else
                        ''
                      end
                    else
                      field.value
                  end
  rescue Selenium::WebDriver::Error::StaleElementReferenceError
    if try_again
      try_again = false
      retry
    end
    raise
  end

  # https://www.seleniumhq.org/exceptions/stale_element_reference.jsp

  expect(field_value).send( (negate ? :not_to : :to),  eq(expected_string) )

end



# Checks that a certain option does or does not exist in a select list
Then "{capture_string} should{negate} have {capture_string} as an option" do | select_list, negate, expected_string |

  field = find_field(select_list)

  select_options= case field.tag_name
                  when 'select'
                    options = field.all('option')
                end
  expect(select_options.map(&:text)).send( (negate ? :not_to : :to),  include( expected_string) )

end


And(/^the "([^"]*)" should( not)? go to "([^"]*)"$/) do |link, negate, url|
  expect(page).send (negate ? :not_to : :to), have_link(link, href: url)
end


And(/^the url "([^"]*)" should( not)? be a valid route$/) do |url, negate |

  if negate
    expect{ visit url }.to  raise_error(ActionController::RoutingError, "No route matches [GET] \"/#{url}\"")
  else
    visit url
  end

end


And(/^the page should( not)? be blank$/) do | negate |
  expect(page.body).send( (negate ? :not_to : :to), be_empty )
end

Then(/^I should get a downloaded image with the filename "([^\"]*)"$/) do |filename|
  expect(page.driver.response_headers['Content-Disposition'])
    .to include("attachment; filename=\"#{filename}\"")
  expect(page.driver.response_headers['Content-Type'])
    .to eq 'image/jpg'
end

When "I cannot select {capture_string} in select list {capture_string}" do |option, list|
  expect(find_field(list).text.match(option)).to be_nil
end


Then("the page title should{negate} be {capture_string}") do | negate, page_title |
  expect(page).send (negate ? :not_to : :to), have_title(page_title)
end


Then("the page head should{negate} include meta {capture_string} {capture_string} with content = {capture_string}") do | negate, meta_tag, value, meta_content|
  meta_xpath = "/html/head/meta[@#{meta_tag}=\"#{value}\"]/@content"
  found_meta_tag  = page.find(meta_xpath, visible: false)

  if negate.nil?
    expect(found_meta_tag.text(:all)).to eq meta_content
  else
    # have to pass :all to .text to get text that is not visible
    expect(found_meta_tag && (found_meta_tag.text(:all) == meta_content)).to be_falsey
  end
end


Then("the page head should{negate} include meta {capture_string} {capture_string}") do | negate, meta_tag, value |
  meta_xpath = "/html/head/meta[@#{meta_tag}=\"#{value}\"]/@content"
  expect(page).send (negate ? :not_to : :to), have_xpath(meta_xpath, visible: false)
end


Then("the page head should{negate} include a link tag with hreflang = {capture_string} and href = {capture_string}") do | negate, hreflang, href |
  hreflang_xpath = "/html/head/link[@rel='alternate'][@hreflang='#{hreflang}'][@href='#{href}']"
  expect(page).send (negate ? :not_to : :to), have_xpath(hreflang_xpath, visible: false)
end


Then("the page head should{negate} include a link tag with rel = {capture_string} and href = {capture_string}") do | negate, rel, href |
  hreflang_xpath = "/html/head/link[@rel='#{rel}'][@href='#{href}']"
  expect(page).send (negate ? :not_to : :to), have_xpath(hreflang_xpath, visible: false)
end


And("the page head should{negate} include a ld+json script tag with key {capture_string}") do | negate, key |
  ld_json = expect_head_has_ld_json_script(negated: negate)

  expect(ld_json.key?(key)).to be_truthy
end


And("the page head should{negate} include a ld+json script tag with key {capture_string} and value {capture_string}") do | negate, key, value |

  ld_json = expect_head_has_ld_json_script(negated: negate)

  expect(ld_json.key?(key)).to be_truthy
  expect(ld_json[key]).to eq value
end


And("the page head should{negate} include a ld+json script tag with key {capture_string} and subkey {capture_string} and value {capture_string}") do | negate, key, subkey, value |

  ld_json = expect_head_has_ld_json_script(negated: negate)

  expect(ld_json.key?(key)).to be_truthy
  expect(ld_json[key].key?(subkey)).to be_truthy
  expect(ld_json[key][subkey]).to eq value
end


And("the page head should{negate} include a ld+json script tag with key {capture_string} and subkey {capture_string} and subkey2 {capture_string} and value {capture_string}") do | negate, key, subkey1, subkey2, value |

  ld_json = expect_head_has_ld_json_script(negated: negate)

  expect(ld_json.key?(key)).to be_truthy
  expect(ld_json[key].key?(subkey1)).to be_truthy
  expect(ld_json[key][subkey1].key?(subkey2)).to be_truthy
  expect((ld_json[key][subkey1][subkey2]).to_s).to eq value
end


def expect_head_has_ld_json_script(negated: false)
  ld_json_text_xpath  = "/html/head/script[@type='application/ld+json']/text()"
  expect(page).send (negated ? :not_to : :to), have_xpath(ld_json_text_xpath, visible: false)

  ld_json = nil
  unless negated
    ld_json_node = find(:xpath, ld_json_text_xpath, visible: false)
    ld_json_text = ld_json_node.text(:all)

    ld_json = JSON.parse(ld_json_text)

    expect(ld_json.key?('@context')).to be_truthy
    expect(ld_json['@context']).to eq 'http://schema.org'

    expect(ld_json.key?('@type')).to be_truthy
    expect(ld_json['@type']).to eq 'LocalBusiness'

    expect(ld_json.key?('@id')).to be_truthy
  end

  ld_json
end
