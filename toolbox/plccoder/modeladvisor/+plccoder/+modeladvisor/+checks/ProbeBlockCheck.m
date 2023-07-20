classdef ProbeBlockCheck < plccoder.modeladvisor.PLCModelAdvisorCheck
    % Stateflow messages are not supported

    properties(Access = protected)
        checkName      = 'ProbeBlockCheck';
        checkGroup     = 'BlockLevelChecks';
    end

    methods(Static)
        function obj = getInstance()
            import plccoder.modeladvisor.checks.*
            persistent instance;
            if isempty(instance)
                instance = ProbeBlockCheck();
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
            probeBlocks = plc_find_system(getfullname(system), 'LookUnderMasks', 'on', 'BlockType', 'Probe');
            if ~isempty(probeBlocks)
                for i=1:numel(probeBlocks)
                    resultStruct = [resultStruct struct(...
                        'ErrorID', 'plccoder:plccg_ext:UnsupportedProbeBlock', ...
                        'Args', {probeBlocks(i)})]; %#ok<AGROW>
                end
            end
        end
    end
end