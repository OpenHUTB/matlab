classdef DSMResolveToSLSignal < plccoder.modeladvisor.PLCModelAdvisorCheck
    % DSM blocks should resolve to signal object unless they are local dsms
    % as part of atomic subcharts and owned by parent stateflow chart

    properties(Access = protected)
        checkName      = 'DSMResolveToSLSignal';
        checkGroup     = 'ModelLevelChecks';
    end

    methods(Static)
        function obj = getInstance()
            import plccoder.modeladvisor.checks.*
            persistent instance;
            if isempty(instance)
                instance = DSMResolveToSLSignal();
            end
            obj = instance;
        end
    end

    methods(Access = protected)
        function resultStruct = runCheck(obj, system)
            % This method runs the check and returns a struct with findings

            resultStruct = [];

            if PLCCoder.PLCCGMgr.getInstance.generateLadderTB
                return;
            end

            modelH = bdroot(getfullname(system)); % TODO: Check if this returns handle/path
            model_has_atomic_subchart = plccoder.modeladvisor.helpers.hasAtomicSubchart(modelH);

            dsm_list = plc_find_system(modelH, 'FollowLinks', 'on', 'LookUnderMasks', ...
                'all', 'LookUnderReadProtectedSubsystems', 'on', 'FindAll', 'on', 'BlockType', 'DataStoreMemory');
            for i = 1 : length(dsm_list)
                if model_has_atomic_subchart && plccoder.modeladvisor.helpers.isDSMOwnedBySF(dsm_list(i))
                    continue;
                elseif (~strcmp(get_param(dsm_list(i), 'StateMustResolveToSignalObject'), 'on'))
                    resultStruct = [resultStruct struct(...
                        'ErrorID', 'plccoder:plccg_ext:DSMNotResolvedToSLSignal', ...
                        'Args', {{getfullname(dsm_list(i))}})]; %#ok<AGROW>
                end
            end
        end
    end
end