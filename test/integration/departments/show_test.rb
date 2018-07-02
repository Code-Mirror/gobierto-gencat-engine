# frozen_string_literal: true

require "test_helper"
require "#{Rails.root}/vendor/gobierto_engines/gobierto-gencat-engine/lib/gencat/integration_test"

module GobiertoPeople
  module Departments
    class ShowTest < ::Gencat::IntegrationTest

      def site
        @site ||= sites(:madrid)
      end

      def department
        @department ||= gobierto_people_departments(:justice_department)
      end

      def test_show
        with_current_site(site) do
          visit gobierto_people_department_path(department)

          assert has_selector?("h3", text: department.name)
        end
      end

    end
  end
end