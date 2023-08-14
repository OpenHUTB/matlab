classdef VoltageCurrentParameters<rf.internal.netparams.AllParameters

    properties(Constant,Access=protected)
        CanAcceptImpedanceInput=false
    end


    methods
        function obj=VoltageCurrentParameters(varargin)
            obj=obj@rf.internal.netparams.AllParameters(varargin{:});
        end
    end


    methods(Access=protected)
        function z0=getDefaultInputImpedance(obj)
            z0=obj.DefaultImpedance;
        end
        function outobj=convertImpedance(inobj,~)
            outobj=inobj;
        end
    end
end