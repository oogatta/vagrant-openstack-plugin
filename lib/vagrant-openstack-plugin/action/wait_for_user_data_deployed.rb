require 'fog'
require 'log4r'

require 'vagrant/util/retryable'

module VagrantPlugins
  module OpenStack
    module Action
      class WaitForUserDataDeployed
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new 'vagrant_openstack::action::wait_for_user_data_deployed'
        end

        def call(env)
          config = env[:machine].provider_config

          env[:ui].info 'waiting for user data deployed.'
          while true
            begin
              break if env[:interrupted]

              @logger.info 'run command that checks user data has deployed.'
              checker = config.command_checks_user_data_finished || '[[ -e /tmp/userdata-deployed ]]'
              break if env[:machine].communicate.execute(checker, error_check: false).eql?(0)
            rescue Errno::ENETUNREACH, Errno::EHOSTUNREACH
            end
            sleep 2
          end

          @app.call(env)
        end
      end
    end
  end
end
