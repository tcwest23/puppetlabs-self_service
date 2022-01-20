# frozen_string_literal: true

require 'singleton'
require 'serverspec'
require 'puppetlabs_spec_helper/module_spec_helper'
include PuppetLitmus

RSpec.configure do |c|
  c.mock_with :rspec
  c.before :suite do
    # Download the plugins to ensure up-to-date facts
    PuppetLitmus::PuppetHelpers.run_shell('/opt/puppetlabs/bin/puppet plugin download')
    pp = <<-PUPPETCODE
    package{'sysstat':
     ensure   => installed,
     }
    PUPPETCODE
    apply_manifest(pp)
    run_shell('echo "puppet_enterprise::enable_system_metrics_collection: true" >> /etc/puppetlabs/code/environments/production/data/common.yaml')
    run_shell('puppet resource service puppet ensure=stopped')
    run_shell('puppet agent -t', expect_failures: true)
    run_shell('puppet resource service puppet ensure=running')
  end
end
