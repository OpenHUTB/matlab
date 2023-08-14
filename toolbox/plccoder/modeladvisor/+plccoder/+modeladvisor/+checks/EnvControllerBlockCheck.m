classdef EnvControllerBlockCheck < plccoder.modeladvisor.PLCModelAdvisorCheck
    % Check if model uses enviornment controller block

    properties(Access = protected)
        checkName      = 'EnvControllerBlockCheck';
        checkGroup     = 'BlockLevelChecks';
    end

    methods(Static)
        function obj = getInstance()
            import plccoder.modeladvisor.checks.*
            persistent instance;
            if isempty(instance)
                instance = EnvControllerBlockCheck();
            end
            obj = instance;
        end
    end

    methods(Access = protected)
        function resultStruct = runCheck(obj, system)
            % This method runs the check and returns a struct with findings

            resultStruct = [];

            modelH = bdroot(system);
            if plccoder.modeladvisor.helpers.checkLadderMdl(modelH)
                return
            end

            % check environment controller block: g2147284
            subsys_list = plc_find_system(system, 'FollowLinks', 'on', 'LookUnderMasks', ...
                'all', 'LookUnderReadProtectedSubsystems', 'on', 'FindAll', 'on', 'BlockType', 'SubSystem');
            for i = 1 : length(subsys_list)
                subsys = subsys_list(i);
                if (strcmp(get_param(subsys, 'Mask'), 'on') && ...
                        strcmp(get_param(subsys, 'MaskType'), 'Environment Controller'))
                    resultStruct = [resultStruct struct(...
                        'ErrorID', 'plccoder:plccg_ext:EnvironmentControllerCheck', ...
                        'Args', {{getfullname(subsys)}})]; %#ok<AGROW>
                end
            end
        end
    end
end