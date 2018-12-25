require 'rails_helper'
require 'email_spec/rspec'


RSpec.describe HBrandingFeePastDueAlert do

  let(:jan_1) { Date.new(2018, 1, 1) }
  let(:dec_1) { Date.new(2018, 12, 1) }
  let(:dec_2) { Date.new(2018, 12, 2) }

  let(:nov_30_last_year) { Date.new(2017, 11, 30) }
  let(:dec_2_last_year) { Date.new(2017, 12, 2) }
  let(:dec_3_last_year) { Date.new(2017, 12, 3) }

  let(:user) { create(:user, email: FFaker::InternetSE.disposable_email) }

  let(:company) { create(:company) }


  let(:config) { { days: [1, 7, 14, 30] } }
  let(:timing) { MembershipExpireAlert::TIMING_AFTER }
  let(:condition) { create(:condition, timing, config) }



  # All examples assume today is 1 December, 2018
  around(:each) do |example|
    Timecop.freeze(dec_1)
    example.run
    Timecop.return
  end


  describe '.send_alert_this_day?(config, user)' do

    context 'h-branding fee is paid is always false' do

      let(:paid_member) {
        member = create(:member_with_membership_app)
        create(:membership_fee_payment,
               :successful,
               user:        member,
               start_date:  jan_1,
               expire_date: User.expire_date_for_start_date(jan_1))
        create(:h_branding_fee_payment,
               :successful,
               user:        member,
               company:     member.companies.first,
               start_date:  jan_1,
               expire_date: User.expire_date_for_start_date(jan_1))
        member
      }

      let(:paid_member_co) { paid_member.companies.first }

      it 'false when the day is in the config list of days to send the alert' do
        expect(described_class.instance.send_alert_this_day?(timing, config, paid_member_co)).to be_falsey
      end

      it 'false when the day  is not in the config list of days to send the alert' do
        expect(described_class.instance.send_alert_this_day?(timing, { days: [999] }, paid_member_co)).to be_falsey
      end

    end

    context 'h-branding fee is not paid' do

      describe 'day 0 for the h-branding fee past due is set once and does not change until it is paid' do

        let(:paid_members_co) { create(:company, name: 'Co with paid members') }

        let(:paid_member_exp_dec31) {
          member = create(:member_with_membership_app, company_number: paid_members_co.company_number)
          create(:membership_fee_payment,
                 :successful,
                 user:        member,
                 company:     paid_members_co,
                 start_date:  jan_1,
                 expire_date: User.expire_date_for_start_date(jan_1))
          member
        }

        let(:paid_member_exp_dec2) {
          member = create(:member_with_membership_app, company_number: paid_members_co.company_number)
          create(:membership_fee_payment,
                 :successful,
                 user:        member,
                 company:     paid_members_co,
                 start_date:  dec_3_last_year,
                 expire_date: User.expire_date_for_start_date(dec_3_last_year))
          member
        }

        let(:condition_config) {  { days: [1] } }

        def print_membership_dates
          print("\nCurrent members membership dates for #{Date.today}:")
          print("\n membership start dates: #{ paid_members_co.current_members.map{|m| { id: m.id, start_date: m.membership_start_date } } }")
          print("\n membership expire dates: #{ paid_members_co.current_members.map{|m| { id: m.id, expire_date: m.membership_expire_date } } }\n")
        end

        it 'saves the oldest (first paid) membership fee payment of all of current members as day 0 past due' do
          paid_members_co
          paid_member_exp_dec31
          paid_member_exp_dec2

          Timecop.freeze(Time.utc(2017, 12, 4)) do
            # update membership status based on today's date
            MembershipStatusUpdater.instance.user_updated(paid_member_exp_dec31)
            MembershipStatusUpdater.instance.user_updated(paid_member_exp_dec2)

            print_membership_dates
            expect(described_class.instance.send_alert_this_day?(timing, condition_config, paid_members_co)).to be_truthy
          end

        end

        it 'if the member with oldest paid membership lets her membership expire, day 0 does not change' do
          pending
          #paid_members_co
          #paid_member_exp_dec31
          #paid_member_exp_dec2

          # Now paid_member_exp_dec2 has expired.  But the expiration date for h_branding should still be set to Dec 2.
          #Timecop.freeze(Date.new(2018, 12, 30)) do
          #
          # update membership status based on today's date
          # MembershipStatusUpdater.instance.user_updated(paid_member_exp_dec31)
          # MembershipStatusUpdater.instance.user_updated(paid_member_exp_dec2)

          #  print_membership_dates
          #  expect(described_class.instance.send_alert_this_day?(timing, condition_config, paid_members_co)).to be_falsey
          #end
        end

      end # describe 'day 0 for the h-branding fee past due is set once and does not change until it is paid'


      context 'membership has not expired yet' do

        let(:paid_member) {
          member = create(:member_with_membership_app)
          create(:membership_fee_payment,
                 :successful,
                 user:        member,
                 start_date:  jan_1,
                 expire_date: User.expire_date_for_start_date(jan_1))
          member
        }

        let(:paid_member_co) { paid_member.companies.first }

        it 'true when the day is in the config list of days to send the alert' do
          Timecop.freeze(Time.utc(2018, 1, 15)) do
            expect(described_class.instance.send_alert_this_day?(timing, config, paid_member_co)).to be_truthy
          end
        end

        it 'false when the day  is not in the config list of days to send the alert' do
          Timecop.freeze(Time.utc(2018, 1, 16)) do
            expect(described_class.instance.send_alert_this_day?(timing, config, paid_member_co)).to be_falsey
          end
        end

      end # context 'membership has not expired yet'


      context 'membership expiration is on or after the given date to check' do

        context 'membership expires 1 day after today (dec 1); expires dec 2' do


          let(:paid_expires_tomorrow_member) {
            shf_accepted_app = create(:shf_application, :accepted)

            member = shf_accepted_app.user

            create(:membership_fee_payment,
                   :successful,
                   user:        member,
                   start_date:  dec_3_last_year,
                   expire_date: User.expire_date_for_start_date(dec_3_last_year))
            member
          }

          let(:paid_member_co) { paid_expires_tomorrow_member.companies.first }


          it 'true if the day is in the config list of days to send the alert (= 1)' do
            Timecop.freeze(Time.utc(2017, 12, 4)) do
              expect(paid_expires_tomorrow_member.membership_expire_date).to eq dec_2
              expect(described_class.instance.send_alert_this_day?(timing, { days: [1] }, paid_member_co)).to be_truthy
            end
          end

          it 'false if the day is not in the config list of days to send the alert' do
            expect(described_class.instance.send_alert_this_day?(timing, { days: [999] }, paid_member_co)).to be_falsey
          end

        end

        context 'membership expires on the given date (dec 1), expired dec 1' do

          let(:paid_expires_today_member) {
            shf_accepted_app = create(:shf_application, :accepted)
            member           = shf_accepted_app.user

            create(:membership_fee_payment,
                   :successful,
                   user:        member,
                   start_date:  dec_2_last_year,
                   expire_date: User.expire_date_for_start_date(dec_2_last_year))
            member
          }

          let(:paid_member_co) { paid_expires_today_member.companies.first }

          it 'false even if the day is in the list of days to send it' do
            expect(paid_expires_today_member.membership_expire_date).to eq dec_1
            expect(described_class.instance.send_alert_this_day?(timing, { days: [0] }, paid_member_co)).to be_falsey
          end

        end

      end # context 'membership expiration is on or after the given date'


      context 'membership has expired' do

        let(:paid_expired_member) {
          shf_accepted_app = create(:shf_application, :accepted)
          member           = shf_accepted_app.user
          create(:membership_fee_payment,
                 :successful,
                 user:        member,
                 start_date:  nov_30_last_year,
                 expire_date: User.expire_date_for_start_date(nov_30_last_year))
          member
        }

        let(:exp_member_co) { paid_expired_member.companies.first }

        it 'false if the day is in the config list of days to send the alert' do
          expect(described_class.instance.send_alert_this_day?(timing, config, exp_member_co)).to be_falsey
        end

        it 'false if the day is not in the config list of days to send the alert' do
          expect(described_class.instance.send_alert_this_day?(timing, { days: [999] }, exp_member_co)).to be_falsey
        end

      end

    end


    context 'company has no current members: always false' do

      let(:company) { create(:company) }

      it 'false when the day is in the config list of days to send the alert' do
        expect(described_class.instance.send_alert_this_day?(timing, config, company)).to be_falsey
      end

      it 'false when the day is not in the config list of days to send the alert' do
        expect(described_class.instance.send_alert_this_day?(timing, { days: [999] }, company)).to be_falsey
      end

    end

  end


  it '.mailer_method' do
    expect(described_class.instance.mailer_method).to eq :h_branding_fee_past_due
  end


  describe 'delivers emails to all current company members' do

    LOG_DIR      = 'tmp'
    LOG_FILENAME = 'testlog.txt'

    after(:all) do
      tmpfile = File.join(Rails.root, LOG_DIR, LOG_FILENAME)
      File.delete(tmpfile) if File.exist?(tmpfile)
    end

    let(:filepath) { File.join(Rails.root, LOG_DIR, LOG_FILENAME) }
    let(:log) { ActivityLogger.open(filepath, 'TEST', 'open', false) }

    let(:paid_member1) {
      member = create(:member_with_membership_app)
      create(:membership_fee_payment,
             :successful,
             user:        member,
             start_date:  jan_1,
             expire_date: User.expire_date_for_start_date(jan_1))
      member
    }

    let(:paid_member_co) { paid_member1.companies.first }

    let(:paid_member2) {
      member = create(:member_with_membership_app, company_number: paid_member_co.company_number)
      create(:membership_fee_payment,
             :successful,
             user:        member,
             start_date:  jan_1,
             expire_date: User.expire_date_for_start_date(jan_1))
      member
    }


    it 'emails sent to all members and logged' do
      paid_member1
      paid_member2
      paid_member_co

      expect(paid_member_co.current_members.size).to eq 2

      Timecop.freeze(jan_1) do
        described_class.instance.send_email(paid_member_co, log)
      end

      expect(ActionMailer::Base.deliveries.size).to eq 2
      expect(File.read(filepath)).to include("[info] HBrandingFeePastDueAlert email sent to user id: #{paid_member1.id} email: #{paid_member1.email} company id: #{paid_member_co.id} name: #{paid_member_co.name}.")
      expect(File.read(filepath)).to include("[info] HBrandingFeePastDueAlert email sent to user id: #{paid_member2.id} email: #{paid_member2.email} company id: #{paid_member_co.id} name: #{paid_member_co.name}.")
    end

  end

end