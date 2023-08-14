classdef RowMajorCheck < plccoder.modeladvisor.PLCModelAdvisorCheck
    % Check if model is set to use row major algorithms

    properties(Access = protected)
        checkName      = 'RowMajorCheck';
        checkGroup     = 'ModelLevelChecks';
    end

    methods(Static)
        function obj = getInstance()
            import plccoder.modeladvisor.checks.*
            persistent instance;
            if isempty(instance)
                instance = RowMajorCheck();
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

            if strcmp(get_param(modelH, 'UseRowMajorAlgorithm'), 'on')
                resultStruct = struct(...
                    'ErrorID', 'plccoder:plccg_ext:UseRowMajorAlgorithm', ...
                    'Args', {{getfullname(modelH)}});
            end
        end
    end
end