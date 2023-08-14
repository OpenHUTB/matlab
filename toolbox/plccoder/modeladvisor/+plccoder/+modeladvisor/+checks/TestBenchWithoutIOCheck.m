classdef TestBenchWithoutIOCheck < plccoder.modeladvisor.PLCModelAdvisorCheck
% Cannot generate testbench when top subsystm ha no IO

    properties(Access = protected)
        checkName      = 'TestBenchWithoutIOCheck';
        checkGroup     = 'BlockLevelChecks';
        mode;
    end

    methods(Static)
        function obj = getInstance()
            import plccoder.modeladvisor.checks.*
            persistent instance;
            if isempty(instance)
                instance = TestBenchWithoutIOCheck();
            end
            obj = instance;
        end
    end

    methods(Access = protected)
        function resultStruct = runCheck(obj, system)
        % This method runs the check and returns a struct with findings

            resultStruct = [];

            if ~ishandle(system)
                system = get_param(system, 'handle');
            end
            % This check used to run on extracted model. However, since
            % this is not required, it will now run on the top level
            % subsystem from original model.
            modelH = system;

            topLevelInputs = plc_find_system(modelH, 'SearchDepth', 1, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'Inport');
            topLevelOutputs = plc_find_system(modelH, 'SearchDepth', 1, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'Outport');
            if obj.mode == 1 % Caller is model advisor
                try
                    hasTB = strcmp(get_param(bdroot(modelH), 'PLC_GenerateTestbench'), 'on');
                catch ME
                    if strcmp(ME.identifier, 'Simulink:Commands:ParamUnknown')
                        hasTB = false;
                    else
                        rethrow(ME);
                    end
                end
            elseif obj.mode == 2 % Caller is plc_mdl_check_initial_property
                hasTB = PLCCoder.PLCCGMgr.getInstance.hasTB;
            else
                hasTB = true;
            end

            if isempty(topLevelInputs) && isempty(topLevelOutputs) && hasTB
                resultStruct = [resultStruct struct(...
                    'ErrorID', 'plccoder:plccg_ext:EmptyTopLevelInputsOutputsTestbench', ...
                    'Args', {{}})];
            end
        end

        function ElementResults = getResultDetailObjs(obj, resultStruct)
            obj.mode = 1;
            ElementResults = getResultDetailObjs@plccoder. ...
                modeladvisor.PLCModelAdvisorCheck(obj, resultStruct);
        end
    end

    methods
        function errorExists = runAsConformanceCheck(obj, system, errorExists)
            obj.mode = 2;
            errorExists = runAsConformanceCheck@plccoder.modeladvisor. ...
                PLCModelAdvisorCheck(obj, system, errorExists);
        end
    end
end
