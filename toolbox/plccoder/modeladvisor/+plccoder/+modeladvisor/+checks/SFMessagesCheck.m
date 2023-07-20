classdef SFMessagesCheck < plccoder.modeladvisor.PLCModelAdvisorCheck
    % Stateflow messages are not supported

    properties(Access = protected)
        checkName      = 'SFMessagesCheck';
        checkGroup     = 'ModelLevelChecks';
    end

    methods(Static)
        function obj = getInstance()
            import plccoder.modeladvisor.checks.*
            persistent instance;
            if isempty(instance)
                instance = SFMessagesCheck();
            end
            obj = instance;
        end
    end

    methods(Access = protected)
        function resultStruct = runCheck(obj, system)
            % This method runs the check and returns a struct with findings

            resultStruct = [];

            modelH = bdroot(system);
            rt = sfroot;
            machineUddH = rt.find('-isa', 'Stateflow.Machine', 'Name', get_param(modelH, 'Name'));
            msgs = [];
            if ~isempty(machineUddH)
                msgs = machineUddH.find('-isa', 'Stateflow.Message');
            end

            if (~isempty(msgs))
                resultStruct = [resultStruct struct(...
                    'ErrorID', 'plccoder:plccg_ext:SFUnsupportedMessages', ...
                    'Args', {{}})];
            end
        end
    end
end