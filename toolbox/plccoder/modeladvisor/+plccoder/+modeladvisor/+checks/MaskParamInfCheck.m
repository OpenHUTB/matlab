classdef MaskParamInfCheck < plccoder.modeladvisor.PLCModelAdvisorCheck
    % Tunable parameters should not contain infinite value

    properties(Access = protected)
        checkName      = 'MaskParamInfCheck';
        checkGroup     = 'ModelLevelChecks';
    end

    methods(Static)
        function obj = getInstance()
            import plccoder.modeladvisor.checks.*
            persistent instance;
            if isempty(instance)
                instance = MaskParamInfCheck();
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

            % check mask param inf values
            subsys_list = plc_find_system(system, 'FollowLinks', 'on', 'LookUnderMasks', ...
                'all', 'LookUnderReadProtectedSubsystems', 'on', 'FindAll', 'on', 'BlockType', 'SubSystem');
            for i = 1 : length(subsys_list)
                subsys = subsys_list(i);
                if (strcmp(get_param(subsys, 'Mask'), 'on'))
                    if (strcmp(get_param(subsys, 'MaskType'), 'Enumerated Constant') || ...
                            strncmp(get_param(subsys, 'MaskType'), 'PID', length('PID'))) % skip enumerate constant, PID
                        continue;
                    end
                    msk = Simulink.Mask.get(subsys);
                    msk_param_list = msk.Parameters;
                    for pi = 1 : length(msk_param_list)
                        msk_param = msk_param_list(pi);
                        if strcmp(msk_param.Value, 'inf') || strcmp(msk_param.Value, '-inf')
                            resultStruct = [resultStruct struct(...
                                'ErrorID', 'plccoder:plccg_ext:UnsupportedMaskParameterInfValue', ...
                                'Args', {{getfullname(subsys), msk_param.Name, msk_param.Value}})]; %#ok<AGROW>
                        end
                    end
                end
            end
        end
    end
end