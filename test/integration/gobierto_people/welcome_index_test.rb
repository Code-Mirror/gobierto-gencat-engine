# frozen_string_literal: true

require "test_helper"
require "#{Rails.root}/vendor/gobierto_engines/gobierto-gencat-engine/lib/gencat/integration_test"

module Gencat
  module GobiertoPeople
    class WelcomeIndexTest < ::Gencat::IntegrationTest

      attr_accessor(
        :site,
        :gift,
        :invitation,
        :department,
        :interest_group,
        :person
      )

      def setup
        update_fixtures_to_match_gencat_data!
        super
        @site = sites(:madrid)
        @gift = gobierto_people_gifts(:aperol_spritz)
        @invitation = gobierto_people_invitations(:richard_paris_invitation_recent)
        @department = gobierto_people_departments(:justice_department)
        @interest_group = gobierto_people_interest_groups(:google)
        @person = gobierto_people_people(:richard)
      end

      def site_attendances_to_events_with_department
        site.event_attendances.where(event: site.events.with_department)
      end

      def interest_groups_counter
        site.interest_groups.count
      end

      def people_box_counter
        site.event_attendances.joins(:event).where("#{GobiertoCalendars::Event.table_name}.department_id is not null").select(:person_id).distinct.count
      end

      def page_title
        "Administration activity viewer"
      end

      def test_welcome_index
        with(js: true, site: site) do
          visit gobierto_people_root_path

          assert title.include? page_title

          within "#meetings-box" do
            assert has_content? "10\nMeetings registered"
          end

          within "#interest-groups-box" do
            assert has_content? "#{interest_groups_counter}\nInterest groups inscribed"
          end

          within "#people-box" do
            assert has_content? "#{people_box_counter}\nOfficials\nwith meetings registered"
          end

          assert map_loaded?

          within "#gifts-wrapper" do
            assert_equal "Gifts", find("#gifts-wrapper section strong").text
            assert has_link? gift.name
            assert has_link? gift.person.name
            assert has_link? "View Officials"
          end

          within "#invitations-wrapper" do
            assert_equal "Invitations", find("#invitations-wrapper section strong").text
            assert has_link? invitation.title
            assert has_link? invitation.person.name
            assert has_link? "View Officials"
          end
        end
      end

      def test_people_search_box
        skip "TODO"
      end

      def test_datepicker
        with(js: true, site: site) do
          visit gobierto_people_root_path

          assert find(".datepicker-container")["class"].exclude? "is-shown"

          find("#datepicker").click

          assert find(".datepicker-container")["class"].include? "is-shown"

          all(".js-datepicker-container a").find { |a| a.text == "Last month" }.click

          expected_path = gobierto_people_root_path(start_date: 1.month.ago.strftime("%F"))

          assert current_url.include? expected_path

          assert_equal page_title, header_title
          assert_equal page_title, breadcrumb_last_item_text
        end
      end

    end
  end
end
