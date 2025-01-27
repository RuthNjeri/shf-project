Feature: Admin sees user account information

  As an admin
  So that I can see and update the account info for a user
  Show me all of the the user account information for a user

  PT:  https://www.pivotaltracker.com/story/show/140358959

  Background:
    Given the App Configuration is not mocked and is seeded

    Given the following users exists
      | email                           | admin | membership_number | member |
      | emma-new-app@bowsers.com        |       |                   |        |
      | lars-member@happymutts.com      |       | 101               | true   |
      | hannah-member@happymutts.com    |       | 102               | true   |
      | rejected@happymutts.com         |       |                   |        |
      | user-never-logged-in@example.se |       |                   |        |
      | user-anna@personal.se           |       |                   |        |
      | user-sam@personal.se            |       |                   |        |
      | admin@shf.se                    | true  |                   |        |
      | yesterday_admin@shf.se          | true  |                   |        |
      | lazy_admin@shf.se               | true  |                   |        |


    And the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |

    And the following companies exist:
      | name        | company_number | email               | region       |
      | Happy Mutts | 5560360793     | woof@happymutts.com | Stockholm    |
      | Bowsers     | 2120000142     | bark@bowsers.com    | Västerbotten |


    And the following applications exist:
      | user_email                   | contact_email           | company_number | state    |
      | lars-member@happymutts.com   | lars@happymutts.com     | 5560360793     | accepted |
      | hannah-member@happymutts.com | hannah@happymutts.com   | 5560360793     | accepted |
      | emma-new-app@bowsers.com     | emma@bowsers.com        | 2120000142     | new      |
      | rejected@happymutts.com      | rejected@happymutts.com | 5560360793     | rejected |


    And the following membership packets have been sent:
      | user_email                 | date_sent  |
      | lars-member@happymutts.com | 2019-03-01 |


    And I am logged in as "admin@shf.se"


  # -----------------------------------
  # Login info - when, how many times

  Scenario: Show an admin who has never logged in
    When I am on the "user details" page for "lazy_admin@shf.se"
    Then I should see t("users.show.is_an_admin")
    And I should see t("users.show.user_has_never_signed_in")
    And I should not see t("users.show.last_login")



  Scenario: Show an admin that is currently logged in
    When I am on the "user details" page for "admin@shf.se"
    Then I should see t("users.show.is_an_admin")
    And I should not see t("users.show.user_has_never_signed_in")
    And I should see t("users.show.last_login")


  Scenario: Show an admin that logged in 1 day ago
    Given The user "yesterday_admin@shf.se" last logged in 1 day ago
    When I am on the "user details" page for "yesterday_admin@shf.se"
    Then I should see t("users.show.is_an_admin")
    And I should not see t("users.show.user_has_never_signed_in")
    And I should see t("users.show.last_login")


  Scenario: Show a member who has never logged in
    When I am on the "user details" page for "hannah-member@happymutts.com"
    Then I should not see t("users.show.is_an_admin")
    And I should see t("users.show.user_has_never_signed_in")
    And I should not see t("users.show.last_login")


  Scenario: Show a member that is currently logged in
    Given The user "emma-new-app@bowsers.com" is currently signed in
    When I am on the "user details" page for "emma-new-app@bowsers.com"
    Then I should not see t("users.show.is_an_admin")
    And I should not see t("users.show.user_has_never_signed_in")
    And I should see t("users.show.last_login")


  Scenario: Show a member that logged 3 days ago
    Given The user "lars-member@happymutts.com" last logged in 3 days ago
    When I am on the "user details" page for "lars-member@happymutts.com"
    Then I should not see t("users.show.is_an_admin")
    And I should not see t("users.show.user_has_never_signed_in")
    And I should see t("users.show.last_login")


  Scenario: Show a member that has logged in 42 times
    Given The user "lars-member@happymutts.com" has logged in 42 times
    When I am on the "user details" page for "lars-member@happymutts.com"
    Then I should see t("users.show.logged_in_count")
    And I should see "42"
    And I should see t("users.show.last_login")


  Scenario: Show an user who has never logged in
    When I am on the "user details" page for "user-never-logged-in@example.se"
    Then I should not see t("users.show.is_an_admin")
    And I should see t("users.show.user_has_never_signed_in")
    And I should not see t("users.show.last_login")


  Scenario: Show an user that is currently logged in
    Given The user "user-anna@personal.se" is currently signed in
    When I am on the "user details" page for "user-anna@personal.se"
    Then I should not see t("users.show.is_an_admin")
    And I should not see t("users.show.user_has_never_signed_in")
    And I should see t("users.show.last_login")


  Scenario: Show an user that logged in 100 days ago
    Given The user "user-sam@personal.se" last logged in 100 days ago
    When I am on the "user details" page for "user-sam@personal.se"
    Then I should not see t("users.show.is_an_admin")
    And I should not see t("users.show.user_has_never_signed_in")
    And I should see t("users.show.last_login")


  # -----------------------------------
  # Password reset info

  Scenario: Show a member that has had her password reset
    Given The user "emma-new-app@bowsers.com" has had her password reset now
    When I am on the "user details" page for "emma-new-app@bowsers.com"
    Then I should see t("users.show.reset_password_sent_at")


  Scenario: Show a member that has never had her password reset
    When I am on the "user details" page for "emma-new-app@bowsers.com"
    Then I should see t("users.show.password_never_reset")


  # -----------------------------------
  # Membership number

  Scenario: Show the membership number for a member
    When I am on the "user details" page for "lars-member@happymutts.com"
    Then I should see t("users.show.membership_number")
    And I should see "101"



  Scenario: Do not show the membership number when there is none
    When I am on the "user details" page for "user-never-logged-in@example.se"
    Then I should not see t("users.show.membership_number")


  # -----------------------------------
  # Email address and application state

  Scenario: Show email addresses and application for a user
    When I am on the "user details" page for "emma-new-app@bowsers.com"
    Then I should see "emma-new-app@bowsers.com"
    And I should see "emma@bowsers.com"
    And I should see "2120000142"
    And I should see t("shf_applications.state.new")
    Then I click on "change-lang-to-english"
    And I should see t("shf_applications.state.new")


  # -----------------------------------
  # Membership Packet info

  Scenario: Membership packet sent to a member: show that it was sent and the date
    When I am on the "user details" page for "lars-member@happymutts.com"
    Then I should see t("users.show.member_packet")
    And I should see t("users.show.sent")
    And I should see "2019-03-01"


  Scenario: Membership packet: If a member but no date sent, should show 'Membership packet not sent'
    When I am on the "user details" page for "hannah-member@happymutts.com"
    Then I should see t("users.show.member_packet")
    And I should see t("users.show.not_sent")


  Scenario: Membership packet info shows for non-members (maybe they used to be a member)
    When I am on the "user details" page for "rejected@happymutts.com"
    Then I should see t("users.show.member_packet")
    And I should see t("users.show.not_sent")


  Scenario: A member cannot see membership packet info
    When I am logged out
    And I am logged in as "lars-member@happymutts.com"
    And I am on the "user details" page for "lars-member@happymutts.com"
    Then I should not see t("users.show.member_packet")


  Scenario: A user cannot see membership packet info
    When I am logged out
    And I am logged in as "user-anna@personal.se"
    And I am on the "user details" page for "user-anna@personal.se"
    Then I should not see t("users.show.member_packet")

