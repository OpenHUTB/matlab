classdef EventBlockCheck < plccoder.modeladvisor.PLCModelAdvisorCheck
    % Check if model contains event based blocks

    properties(Access = protected)
        checkName      = 'EventBlockCheck';
        checkGroup     = 'BlockLevelChecks';
    end

    methods(Static)
        function obj = getInstance()
            import plccoder.modeladvisor.checks.*
            persistent instance;
            if isempty(instance)
                instance = EventBlockCheck();
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

            eventBlocks = plc_find_system(bdroot(getfullname(modelH)),'LookUnderMasks','all','BlockType','EventListener');
            if ~isempty(eventBlocks)
                parentBlocks = get_param(eventBlocks, 'Parent');
                for i=1:numel(parentBlocks)
                    resultStruct = [resultStruct struct(...
                        'ErrorID', 'plccoder:plccg_ext:UnsupportedEventBlock', ...
                        'Args', {parentBlocks(i)})]; %#ok<AGROW>
                end
            end
        end
    end

    methods
        function errorExists = runAsConformanceCheck(obj, system, errorExists)
            % This method runs the check and throws errors

            resultStruct = obj.runCheck(system);
            resultStruct = obj.filterExternallyDefinedBlocks(resultStruct);

            if numel(resultStruct) == 1
                errorExists = true; %#ok<NASGU>
                error(message(resultStruct(1).ErrorID, resultStruct(1).Args{:}));
            elseif numel(resultStruct) > 1
                errorExists = true;
                msl = MSLDiagnostic([], 'plccoder:plccg_ext:PLCErrorGroup', message('plccoder:plccg_ext:PLCErrorGroup').getString);
                for i = 1:numel(resultStruct)
                    msl = msl.addCause(MSLDiagnostic([],...
                        resultStruct(i).ErrorID, ...
                        message(resultStruct(i).ErrorID, resultStruct(i).Args{:}).getString));
                end
                msl.reportAsError;
            end
        end
    end
end