# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/app/models/server_capabilities'
require_relative '../../lib/app/models/testing_instance'

class ServerCapabilitiesTest < MiniTest::Test
  def setup
    @capability_statement = {
      rest: [
        {
          resource: [
            {
              type: 'Patient',
              interaction: [
                { code: 'read' },
                { code: 'vread' },
                { code: 'history-instance' },
                { code: 'search-type' }
              ]
            },
            {
              type: 'Condition',
              interaction: [
                { code: 'delete' },
                { code: 'update' }
              ]
            },
            {
              type: 'Observation'
            }
          ]
        }
      ]
    }

    @capabilities = Inferno::Models::ServerCapabilities.new(
      testing_instance_id: Inferno::Models::TestingInstance.create.id,
      capabilities: @capability_statement
    )
  end

  def test_supported_resources
    expected_resources = Set.new(['Patient', 'Condition', 'Observation'])

    assert @capabilities.supported_resources == expected_resources
  end

  def test_supported_interactions
    expected_interactions = [
      {
        resource_type: 'Patient',
        interactions: ['history-instance', 'read', 'search', 'vread']
      },
      {
        resource_type: 'Condition',
        interactions: ['delete', 'update']
      },
      {
        resource_type: 'Observation',
        interactions: []
      }
    ]

    assert @capabilities.supported_interactions == expected_interactions
  end

  def test_operation_supported_pass
    conformance = load_json_fixture(:bulk_data_conformance)

    server_capabilities = Inferno::Models::ServerCapabilities.new(
      testing_instance_id: Inferno::Models::TestingInstance.create.id,
      capabilities: conformance.as_json
    )

    assert server_capabilities.operation_supported?('patient-export')
  end

  def test_operation_supported_fail_invalid_name
    conformance = load_json_fixture(:bulk_data_conformance)

    server_capabilities = Inferno::Models::ServerCapabilities.new(
      testing_instance_id: Inferno::Models::TestingInstance.create.id,
      capabilities: conformance.as_json
    )

    assert !server_capabilities.operation_supported?('this_is_a_test')
  end
end
