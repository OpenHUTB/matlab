
%

%   Copyright 2020 The MathWorks, Inc.
classdef Converter < handle
    properties(Access = protected)
        chartObj;
        doCasting;
        stateTransitionIds;
        groupedStatesUddH;
        currentObjId;
    end
    methods
        function this = Converter(chartObj, varargin)
            CHART_OBJECT = 1;
            if isempty(chartObj) || sf('get', chartObj.Id, '.isa') ~= CHART_OBJECT
                error('Stateflow:Tools:Classic2MALConverter:InvalidInput', ...
                    'First input of Classic2MALConverter must be a Stateflow.Chart or a Stateflow.StateTransitionTableChart object');
            end
            this.chartObj = chartObj;
            this.getAllStatesTransitions;
        end
        
        function getAllStatesTransitions(this)
            % getAllStatesTransitions - serves two purposes:
            % 1. Return a list of states and transitions to be visited
            % 2. To ungroup grouped states and boxes.
            
            stateIds = sf('SubstatesIn', this.chartObj.Id);
            
            % Filter out atomic subcharts and action states.e
            stateIds = sf('find', stateIds, 'state.simulink.isComponent', 0);
            stateIds = sf('find', stateIds, 'state.simulink.isActionSubsystem', 0);
            
            this.stateTransitionIds = [stateIds sf('get', this.chartObj.Id, '.transitions')];
            
            this.groupedStatesUddH = this.getHierarchicalListOfGroupedStates(this.chartObj);
            
            for i = 1:numel(this.groupedStatesUddH)
                this.groupedStatesUddH(i).isGrouped = false;
            end
        end
        
        function groupedStateBoxIds = getHierarchicalListOfGroupedStates(this, objectUddH)
            
            subStates = objectUddH.find('-depth', 1, ...
                '-isa', 'Stateflow.State', '-or', ...
                '-isa', 'Stateflow.Function', '-or',...
                '-isa', 'Stateflow.Box');
            
            groupedStateBoxIds = [];
            
            if ~(isa(objectUddH, 'Stateflow.Chart') || isa(objectUddH, 'Stateflow.StateTransitionTableChart')) && objectUddH.isGrouped
                groupedStateBoxIds = [objectUddH groupedStateBoxIds];
            end
            
            startIndex = this.getStartIndex(subStates, objectUddH);
            for i = startIndex:numel(subStates)
                groupedStateBoxIds = [groupedStateBoxIds, this.getHierarchicalListOfGroupedStates(subStates(i))]; %#ok<AGROW>
            end
        end
        
        function startIndex = getStartIndex(~, array, objectUddH)
            if ~isempty(array) && strcmp(class(array(1)), class(objectUddH)) && array(1) == objectUddH
                % skipping the first one because it is itself
                startIndex = 2;
            else
                startIndex = 1;
            end
        end
        
        function updateLabelString(~, objId, newString)
            
            converterInst = Stateflow.Tools.SyntaxCorrectorToMATLAB.currentConverterInstance();
            if ~isempty(converterInst)
                converterInst.ModifiedObjectIds(end + 1) = objId;
            end
            % Using M3I API so that this is undoable
            m3iObj = StateflowDI.SFDomain.id2DiagramElement(objId);
            
            if ~isempty(m3iObj)
                try
                    m3iObj.label = newString;
                catch  %assertion about root deviant not opened for transactions if it is inside truth table, subcharted etc.
                    handle = idToHandle(sfroot, objId);
                    handle.LabelString = newString;
                end
            else
                handle = idToHandle(sfroot, objId);
                handle.LabelString = newString;
            end
        end
    end
end