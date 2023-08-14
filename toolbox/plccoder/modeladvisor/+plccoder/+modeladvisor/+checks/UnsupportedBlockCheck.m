classdef UnsupportedBlockCheck < plccoder.modeladvisor.PLCModelAdvisorCheck
    % Stateflow messages are not supported

%   Copyright 2021 The MathWorks, Inc.

    properties(Access = protected)
        checkName      = 'UnsupportedBlockCheck';
        checkGroup     = 'ModelLevelChecks';
    end

    methods(Static)
        function obj = getInstance()
            import plccoder.modeladvisor.checks.*
            persistent instance;
            if isempty(instance)
                instance = UnsupportedBlockCheck();
            end
            obj = instance;
        end
    end

    methods(Access = protected)
        function resultStruct = runCheck(obj, system) %#ok<INUSL> 
            % This method runs the check and returns a struct with findings

            resultStruct = [];

            if ~ishandle(system)
                system = get_param(system, 'handle');
            end
            unsupportedBlockTypes = {'Integrator', 'RandomNumber', 'Merge', 'ModelReference', 'Lookup', 'Lookup2D', 'Lookup_n-D', 'PreLookup', 'Math', 'S-Function', ...
                'ForEach', 'SwitchCase', 'Width', 'Clock', 'DigitalClock', 'Step', 'FunctionCaller', 'SubSystem', 'MATLABSystem', 'CFunction', ...
                'Interpolation_n-D', 'TriggerPort', 'Find'};

            if plcfeature('PLCForEachBlockCG') % support ForEach
                foreach_idx = ismember(unsupportedBlockTypes, 'ForEach');
                unsupportedBlockTypes(foreach_idx) = [];
            end

            opts = {'FollowLinks', 'on', 'LookUnderMasks', 'all', 'LookUnderReadProtectedSubsystems', 'on'};
            aBlks = plc_find_system(system, opts{:});
            aBlks(1) = []; % The first element is the model
            aBlkTypes = get_param(aBlks,'BlockType');

            % Blocks that are not supported
            for i=1:length(unsupportedBlockTypes)
                indexArray = find(strcmp(unsupportedBlockTypes{i},aBlkTypes));

                for j=1:length(indexArray)
                    block = aBlks(indexArray(j));
                    blockType = unsupportedBlockTypes{i};

                    if strcmp(blockType, 'Merge')
                        % we throw proper errors for merge block used for atomic subcharts
                        % later; so skip them here
                        parent = get_param(block, 'Parent');
                        if(Stateflow.SLUtils.isStateflowBlock(parent))
                            continue;
                        end
                    elseif strcmp(blockType, 'Lookup_n-D')
                        % do some basic conformance checks for unsupported lookup
                        % tables
                        try
                            if str2double(get_param(block, 'NumberOfTableDimensions')) > 2
                                errMsg = sprintf('Block ''%s'' of type ''%s'' is configured for more than 2 table dimensions. This is not supported by PLC Coder.', getfullname(block), blockType);
                                resultStruct = [resultStruct struct(...
                                    'ErrorID', 'PLCCoder:UnsupportedBlockType', ...
                                    'Args', {{errMsg}}, 'hasStringMessage', true)]; %#ok<AGROW>
                            end
                            if ~strcmp(get_param(block, 'BeginIndexSearchUsingPreviousIndexResult'), 'off')
                                errMsg = sprintf('Block ''%s'' of type ''%s'' is configured with ''Begin Index Search Using Previous Index Result'' turned on. This is not supported by PLC Coder.', getfullname(block), blockType);
                                resultStruct = [resultStruct struct(...
                                    'ErrorID', 'PLCCoder:UnsupportedBlockType', ...
                                    'Args', {{errMsg}}, 'hasStringMessage', true)]; %#ok<AGROW>
                            end
                            if strcmp(get_param(block, 'InterpMethod'), 'Cubic spline')
                                errMsg = sprintf('Block ''%s'' of type ''%s'' is configured for ''Cubic spline'' interpolation method. This is not supported by PLC Coder.', getfullname(block), blockType);
                                resultStruct = [resultStruct struct(...
                                    'ErrorID', 'PLCCoder:UnsupportedBlockType', ...
                                    'Args', {{errMsg}}, 'hasStringMessage', true)]; %#ok<AGROW>
                            end
                            if strcmp(get_param(block, 'ExtrapMethod'), 'Cubic spline')
                                errMsg = sprintf('Block ''%s'' of type ''%s'' is configured for ''Cubic spline'' extrapolation method. This is not supported by PLC Coder.', getfullname(block), blockType);
                                resultStruct = [resultStruct struct(...
                                    'ErrorID', 'PLCCoder:UnsupportedBlockType', ...
                                    'Args', {{errMsg}}, 'hasStringMessage', true)]; %#ok<AGROW>
                            end
                        catch merr %#ok<NASGU>
                        end
                        continue;
                    elseif strcmp(blockType, 'PreLookup')
                        % do some basic conformance checks for unsupported lookup
                        % tables
                        try
                            if ~strcmp(get_param(block, 'BeginIndexSearchUsingPreviousIndexResult'), 'off')
                                errMsg = sprintf('Block ''%s'' of type ''%s'' is configured with ''Begin Index Search Using Previous Index Result'' turned on. This is not supported by PLC Coder.', getfullname(block), blockType);
                                resultStruct = [resultStruct struct(...
                                    'ErrorID', 'PLCCoder:UnsupportedBlockType', ...
                                    'Args', {{errMsg}}, 'hasStringMessage', true)]; %#ok<AGROW>
                            end
                        catch merr %#ok<NASGU>
                        end
                        continue;
                    elseif strcmp(blockType, 'Lookup') || strcmp(blockType, 'Lookup2D')
                        try
                            errMsg = sprintf(['Block ''%s'' of type ''%s'' is deprecated by Simulink and not supported by PLC Coder. To achieve the same functionality, use the n-D Lookup Table block (in <a href="matlab:load_system(''plclib'');open_system(''plclib/Simulink/Lookup Tables'')">plclib/Simulink/Lookup Tables</a>). ' ...
                                'Alternatively, to automatically replace this block, run the ''upgradeadvisor(<modelName>)'' command at the MATLAB prompt.'], getfullname(block), blockType);
                            resultStruct = [resultStruct struct(...
                                'ErrorID', 'PLCCoder:UnsupportedBlockType', ...
                                'Args', {{errMsg}}, 'hasStringMessage', true)]; %#ok<AGROW>
                        catch merr %#ok<NASGU>
                        end
                        continue;
                    elseif strcmp(blockType, 'Math')
                        try
                            operator = get_param(block, 'Operator');
                            if strcmp(operator, 'sqrt')
                                errMsg = sprintf(['Block ''%s'' of type ''%s'' is configured to use the ''sqrt'' operator which is deprecated by Simulink and not supported by PLC Coder. To achieve the same functionality, use the Simulink Sqrt block (in <a href="matlab:load_system(''plclib'');open_system(''plclib/Simulink/Math Operations'')">plclib/Simulink/Math Operations</a>). ' ...
                                    'Alternatively, to automatically replace this block, run the ''upgradeadvisor(<modelName>)'' command at the MATLAB prompt.'], getfullname(block), blockType);
                                resultStruct = [resultStruct struct(...
                                    'ErrorID', 'PLCCoder:UnsupportedBlockType', ...
                                    'Args', {{errMsg}}, 'hasStringMessage', true)]; %#ok<AGROW>
                            end
                        catch merr %#ok<NASGU>
                        end
                        continue;
                    elseif strcmp(blockType, 'S-Function')
                        try
                            maskType = get_param(block, 'MaskType');
                            if strcmp(maskType, 'Lookup Table Dynamic')
                                errMsg = sprintf(['Block ''%s'' of type ''%s'' is not supported by PLC Coder. To achieve the same functionality, use a combination of the ''Prelookup'' and ''Interpolation Using Prelookup'' blocks. ' ...
                                    'plclib contains a Lookup Table Dynamic block implemented using this technique (in <a href="matlab:load_system(''plclib'');open_system(''plclib/Simulink/Lookup Tables'')">plclib/Simulink/Lookup Tables</a>). You can ' ...
                                    'replace the block in your model with this dynamic block equivalent from plclib.'], getfullname(block), maskType);
                                resultStruct = [resultStruct struct(...
                                    'ErrorID', 'PLCCoder:UnsupportedBlockType', ...
                                    'Args', {{errMsg}}, 'hasStringMessage', true)]; %#ok<AGROW>
                            elseif strcmp(maskType, 'Integrate and Dump')
                                errMsg = sprintf('Block ''%s'' of type ''%s'' is not supported by Simulink PLC Coder.', getfullname(block), maskType);
                                resultStruct = [resultStruct struct(...
                                    'ErrorID', 'PLCCoder:UnsupportedBlockType', ...
                                    'Args', {{errMsg}}, 'hasStringMessage', true)]; %#ok<AGROW>
                            end

                        catch merr %#ok<NASGU>
                        end
                        continue;
                    elseif strcmp(blockType, 'SubSystem')
                        maskType = get_param(block, 'MaskType');
                        if ~isempty(maskType)
                            if  strcmp(maskType, 'System Outputs')
                                resultStruct = [resultStruct struct(...
                                    'ErrorID', 'plccoder:plccg_ext:UnsupportedSystemOutputCustomCodeBlock', ...
                                    'Args', {{getfullname(block)}}, 'hasStringMessage', false)]; %#ok<AGROW>
                            elseif strcmp(maskType, 'Sine and Cosine') && ~PLCCoder.PLCCGMgr.getInstance.hasTargetUnsignedInteger
                                resultStruct = [resultStruct struct(...
                                    'ErrorID', 'plccoder:plccg_ext:UnsupportedSineCosineBlock', ...
                                    'Args', {{getfullname(block), PLCCoder.PLCCGMgr.getInstance.getTargetIDE}}, ...
                                    'hasStringMessage', false)]; %#ok<AGROW>
                            end
                        end
                        try
                            sType = Simulink.SubsystemType(block);
                            if strcmp(sType.getType, 'Simulink Function')
                                errMsg = sprintf('Block ''%s'' of type ''%s'' is not supported by PLC Coder.', getfullname(block), sType.getType);
                                resultStruct = [resultStruct struct(...
                                    'ErrorID', 'PLCCoder:UnsupportedBlockType', ...
                                    'Args', {{errMsg}}, 'hasStringMessage', true)]; %#ok<AGROW>
                            end
                        catch merr %#ok<NASGU>
                        end
                        continue;
                    elseif strcmp(blockType, 'Interpolation_n-D')
                        dim_sz = str2double(get_param(block, 'NumberOfTableDimensions'));
                        if (dim_sz>5) % g2356221
                            resultStruct = [resultStruct struct(...
                                'ErrorID', 'plccoder:plccg_ext:UnsupportedInterpolationDimSize', ...
                                'Args', {{getfullname(block)}}, 'hasStringMessage', false)]; %#ok<AGROW>
                        end
                        continue;
                    elseif strcmp(blockType, 'TriggerPort')
                        triggerType = get_param(block, 'TriggerType');
                        if strcmp(triggerType, 'function-call')
                            parentBlk = get_param(block, 'Parent');
                            ph = get_param(parentBlk, 'PortHandles');
                            if numel(ph.Trigger) == 1
                                dim = 0;
                                try
                                    feval(getfullname(bdroot(block)), [], [], [], 'compile');
                                    dim = get_param(ph.Trigger, 'CompiledPortWidth');
                                    feval(bdroot(block), [], [], [], 'term');
                                catch
                                    feval(getfullname(bdroot(block)), [], [], [], 'term');
                                end
                                if dim > 1
                                    resultStruct = [resultStruct struct(...
                                        'ErrorID', 'plccoder:plccg_ext:UnsupportedTriggerPort', ...
                                        'Args', {{getfullname(block)}}, 'hasStringMessage', false)]; %#ok<AGROW>
                                end
                            end
                        end
                        continue;
                    end

                    errMsg = sprintf('Block ''%s'' of type ''%s'' is not supported by PLC Coder.', getfullname(block), blockType);
                    resultStruct = [resultStruct struct(...
                        'ErrorID', 'PLCCoder:UnsupportedBlockType', ...
                        'Args', {{errMsg}}, 'hasStringMessage', true)]; %#ok<AGROW>
                end
            end
        end
    end

    methods
        function errorExists = runAsConformanceCheck(obj, system, errorExists)
            % This method runs the check and throws errors

            resultStruct = obj.runCheck(system);
            resultStruct = obj.filterExternallyDefinedBlocks(resultStruct);

            modelH = bdroot(system);
            for i=1:numel(resultStruct)
                errorExists = true;
                if resultStruct(i).hasStringMessage
                    errMsg = resultStruct(i).Args{:};
                    errId = resultStruct(i).ErrorID;
                    sldvshareprivate('avtcgirunsupcollect', 'push',modelH,'simulink',errMsg,errId);
                else
                    error(message(resultStruct(i).ErrorID, resultStruct(i).Args{:}));
                end
            end
        end
    end
end

% LocalWords:  CFunction subcharts Extrap plclib upgradeadvisor Prelookup plccg avtcgirunsupcollect
