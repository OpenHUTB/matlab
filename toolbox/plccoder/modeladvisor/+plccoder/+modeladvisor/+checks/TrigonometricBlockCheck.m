classdef TrigonometricBlockCheck < plccoder.modeladvisor.PLCModelAdvisorCheck
    % Checks if trigonometry blocks have supported settings

%   Copyright 2021 The MathWorks, Inc.

    properties(Access = protected)
        checkName       = 'TrigonometricBlockCheck';
        checkGroup      = 'BlockLevelChecks';
    end

    methods(Access = protected)
        function obj = TrigonometricBlockCheck()
            obj.callbackContext = 'PostCompile';
        end
    end

    methods(Static)
        function obj = getInstance()
            import plccoder.modeladvisor.checks.*
            persistent instance;
            if isempty(instance)
                instance = TrigonometricBlockCheck();
            end
            obj = instance;
        end
    end

    methods (Access = protected)
        function resultStruct = runCheck(obj, system) %#ok<INUSL> 
            % This method runs the check and returns a struct with findings

            resultStruct = [];
            trigblk_list = plc_find_system(system, 'FollowLinks', 'on', 'LookUnderMasks', ...
                'all', 'LookUnderReadProtectedSubsystems', 'on', 'FindAll', 'on', 'BlockType', 'Trigonometry');
            if isempty(trigblk_list)
                return;
            end

            originalMode = get_param(bdroot(system), 'SimulationMode');
            if strcmpi(originalMode, 'accelerator')
                % Accelerator mode is not supported for the model compile command.
                set_param(bdroot(system), 'SimulationMode', 'normal');
                resetMode = onCleanup(@()set_param(bdroot(system), 'SimulationMode', originalMode));
            end

            for i = 1 : length(trigblk_list)
                trigblk = trigblk_list(i);
                if (strcmp(get_param(trigblk, 'Operator'), 'atan2') && ...
                        strcmp(get_param(trigblk, 'ApproximationMethod'), 'CORDIC'))
                    type_list = get_param(trigblk, 'CompiledPortDataTypes');
                    assert(~isempty(type_list));
                    output_type = type_list.Outport{1};
                    if (startsWith(output_type, 'sfix')) % check sfix output type
                        idx = strfind(output_type, '_');
                        assert(idx>length('sfix')+1);
                        output_bitwidth = str2num(output_type(length('sfix')+1:idx-1)); %#ok<ST2NM>
                        if (output_bitwidth>30)
                            resultStruct = [resultStruct struct(...
                                'ErrorID', 'plccoder:plccg_ext:TrigonometryBlockAtan2CORDIC', ...
                                'Args', {{getfullname(trigblk),  output_type}})]; %#ok<AGROW>
                        end
                    end
                end
            end
        end
    end

    methods
        function errorExists = runAsConformanceCheck(obj, system, errorExists)
            % This method runs the check and throws errors

            % Skip check if no trigonometric blocks found
            trigblk_list = plc_find_system(system, 'FollowLinks', 'on', 'LookUnderMasks', ...
                'all', 'LookUnderReadProtectedSubsystems', 'on', 'FindAll', 'on', 'BlockType', 'Trigonometry');
            if isempty(trigblk_list)
                return;
            end

            modelName = get_param(bdroot(system), 'Name');
            feval(modelName, [],[],[],'compile');
            resultStruct = obj.runCheck(system);
            feval(modelName, [],[],[],'term');

            resultStruct = obj.filterExternallyDefinedBlocks(resultStruct);
            if ~isempty(resultStruct)
                errorExists = true; %#ok<NASGU>
                error(message(resultStruct(1).ErrorID, resultStruct(1).Args{:}));
            end
        end
    end
end

% LocalWords:  plccg
