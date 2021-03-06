require 'shell_mock/monkey_patch'
require 'shell_mock/stub_registry'
require 'shell_mock/no_stub_specified'
require 'shell_mock/spawn_arguments'

module ShellMock
  class SystemMonkeyPatch < MonkeyPatch
    def method_name
      :system
    end

    def override(*args)
      env, command, options = SpawnArguments(*args)

      stub = StubRegistry.stub_matching(env, command, options)

      if stub
        stub.ran

        stub.side_effect.call

        __un_shell_mocked_system(stub.to_oneliner)
      else
        if ShellMock.let_commands_run?
          __un_shell_mocked_system(env, command, options)
        else
          raise NoStubSpecified.new(command)
        end
      end
    end
  end
end
