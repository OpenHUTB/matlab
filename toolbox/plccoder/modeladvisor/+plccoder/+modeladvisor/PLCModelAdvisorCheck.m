classdef (Abstract) PLCModelAdvisorCheck < handle
% PLCModelAdvisorCheck Base class for PLC Model Advisor Checks

%   Copyright 2021-2022 The MathWorks, Inc.

    properties(Abstract, Access = protected)
        % Initialize the following properties in derived class's
        % properties

        % Check (class) name
        checkName;

        % Check Group
        %   'ModelLevelChecks'
        %   'SubsystemLevelChecks'
        %   'BlockLevelChecks'
        %   'IndustryStandardChecks'
        checkGroup;
    end

    properties(Access = protected)
        % Callback context specifies when to run the check
        %   'PostCompileForCodegen'
        %   'PostCompile'
        %   'None'
        callbackContext = 'None';
        % Use method setCallbackContext to override callback context from
        % child class
    end

    methods(Abstract, Static)
        % Define static method to get singleton instance of class in
        % derived class
        obj = getInstance();
    end

    methods(Abstract, Access = protected)
        % Define method with check logic in derived class. This method
        % should return an array of struct such that:
        % resultStruct(idx): Struct with following fields
        %   ErrorID: Error id string
        %   Args   : Cell array of args
        resultStruct = runCheck(obj, system);
    end

    methods
        function register(obj)
        % This method registers the check with Model Advisor

            rec = obj.createCheckObj();
            rec.setReportStyle('plccoder.modeladvisor.PLCStyle');
            rec.setSupportedReportStyles({'plccoder.modeladvisor.PLCStyle'});
            obj.setCallback(rec);
            obj.publish(rec);
        end

        function modelAdvisorCallback(obj, system, checkObj)
            mdladvObj = Simulink.ModelAdvisor.getModelAdvisor(system);
            mdladvObj.setCheckErrorSeverity(1);
            mdladvObj.setCheckResultStatus(false);

            % If check not run on a block, fail the check
            if ~strcmp(get_param(system,'Type'), 'block')
                resultObj(1, 1) = ModelAdvisor.ResultDetail;
                resultObj.Status = 'No block selected in the following model';
                resultObj.RecAction = 'Open Model Advisor with top-level subsystem selected';
                resultObj.Data = system;
                checkObj.setResultDetails(resultObj);
                return;
            end

            resultStruct = obj.runCheck(system);
            resultStruct = obj.filterExternallyDefinedBlocks(resultStruct, system);
            if isempty(resultStruct)
                mdladvObj.setCheckResultStatus(true);
            end

            resultDetails = obj.getResultDetailObjs(resultStruct);
            checkObj.setResultDetails(resultDetails);
        end

        function errorExists = runAsConformanceCheck(obj, system, errorExists)
        % This method runs the check and throws errors

            resultStruct = obj.runCheck(system);
            resultStruct = obj.filterExternallyDefinedBlocks(resultStruct);

            if ~isempty(resultStruct)
                errorExists = true; %#ok<NASGU>
                error(message(resultStruct(1).ErrorID, resultStruct(1).Args{:}));
            end
        end
    end

    methods(Access = protected)
        function resultStruct = filterExternallyDefinedBlocks(obj, resultStruct, varargin) %#ok<INUSL>

            if ~isempty(varargin)
                modelH = bdroot(varargin{1});
                externalBlocks = plccoder.modeladvisor.helpers.getExternallyDefinedBlockPaths(modelH);
            else
                externalBlocks = PLCCoder.PLCCGMgr.getInstance.getExternBlockPaths;
            end

            excludeIdxs = [];
            for i = 1:numel(resultStruct)
                if isfield(resultStruct(i), 'hasStringMessage') && ...
                        resultStruct(i).hasStringMessage
                    if contains(resultStruct(i).Args, externalBlocks)
                        excludeIdxs = [excludeIdxs i]; %#ok<AGROW>
                    end
                else
                    if any(contains(resultStruct(i).Args, externalBlocks))
                        excludeIdxs = [excludeIdxs i]; %#ok<AGROW>
                    end
                end
            end
            resultStruct(excludeIdxs) = [];
        end

        function rec = createCheckObj(obj)
            rec = ModelAdvisor.Check(['mathworks.PLC.' obj.checkName]);
            rec.Title = DAStudio.message(['plccoder:modeladvisor:' obj.checkName 'Title']);
            rec.TitleTips = DAStudio.message(['plccoder:modeladvisor:' obj.checkName 'TitleTips']);
            rec.LicenseName = {'Simulink_PLC_Coder'};
            rec.CSHParameters.MapKey='plcmodeladvisor';
            rec.CSHParameters.TopicID = rec.ID;
            rec.ListViewVisible = false;
        end

        function setCallback(obj, rec)
            rec.setCallbackFcn(@obj.modelAdvisorCallback,'None','DetailStyle');
            rec.CallbackContext = obj.callbackContext;
            if ~strcmp(rec.CallbackContext, 'None')
                rec.Value = false;
            end
        end

        function publish(obj, rec)
            mdladvRoot = ModelAdvisor.Root;
            mdladvRoot.publish(rec, [ ...
                                      DAStudio.message('plccoder:modeladvisor:ProductName') '|' ...
                                      DAStudio.message(['plccoder:modeladvisor:' obj.checkGroup 'Name'])]);
        end

        function ElementResults = getResultDetailObjs(obj, resultStruct)
            if ~isempty(resultStruct)
                ElementResults(1,numel(resultStruct)) = ModelAdvisor.ResultDetail;
                for i = 1:numel(resultStruct)
                    ElementResults(i).Status = DAStudio.message(['plccoder:modeladvisor:' obj.checkName 'SubStatusText']);
                    ElementResults(i).RecAction = DAStudio.message(['plccoder:modeladvisor:' obj.checkName 'RecAction']);
                    %ElementResults(i).Type = 'String';
                    if isfield(resultStruct, 'hasStringMessage') && resultStruct(i).hasStringMessage
                        ElementResults(i).Data = resultStruct(i).Args{:};
                    else
                        ElementResults(i).Data = DAStudio.message(resultStruct(i).ErrorID, resultStruct(i).Args{:});
                    end
                    ElementResults(i).Description = DAStudio.message(['plccoder:modeladvisor:' obj.checkName 'Text']);
                end
            else
                ElementResults = ModelAdvisor.ResultDetail;
                ElementResults.IsViolation = false;
                ElementResults.Description = DAStudio.message(['plccoder:modeladvisor:' obj.checkName 'Text']);
            end
        end
    end
end

% LocalWords:  plcmodeladvisor
