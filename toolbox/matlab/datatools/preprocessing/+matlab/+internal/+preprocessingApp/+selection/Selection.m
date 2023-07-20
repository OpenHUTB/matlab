classdef Selection < handle
    % SELECTION 
    % Singleton class to keep track of selection inside the App
    
    properties(GetAccess = public, SetAccess = private)
        SelectedVariable
        SelectedTableVariables
        LastChangedSrc 
    end
    
    properties
        SelectionChanged
    end
    
    methods(Access='protected')
        function this = Selection()
        end
    end
    
    methods(Static, Access='public')
        function obj = getInstance(varargin)
            %mlock; % Keep persistent variables until MATLAB exits
            persistent selectionInstance;
            if isempty(selectionInstance)
                selectionInstance = matlab.internal.preprocessingApp.selection.Selection();
            end
            obj = selectionInstance;
        end
    end
    
    methods
        function setSelection(obj, val, notify)
            if isfield(val, 'SelectedVariable')
                obj.SelectedVariable = string(val.SelectedVariable);
            end
            
            if isfield(val, 'SelectedTableVariables')
                obj.SelectedTableVariables = string(val.SelectedTableVariables);
            end
            
            if isfield(val, 'LastChangedSrc')
                obj.LastChangedSrc = val.LastChangedSrc;
            end
            
            if (notify)
                obj.SelectionChanged();
            end
        end
    end
end

