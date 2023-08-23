classdef Add<driving.internal.scenarioApp.undoredo.Edit

    properties(SetAccess=protected)
        Inputs
    end


    properties(Access=protected)
        Specification
    end

    
    methods
        function this=Add(hDesigner,varargin)
            this.Application=hDesigner;
            this.Inputs=varargin;
        end
    end
end


