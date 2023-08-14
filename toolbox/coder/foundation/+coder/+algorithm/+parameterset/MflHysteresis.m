classdef MflHysteresis<coder.algorithm.parameterset.AlgorithmParameterSet

    properties(Hidden,Dependent,SetAccess=public,GetAccess=private)

    end

    properties(SetAccess=public,GetAccess=public)
        SwitchingPoint=coder.algorithm.parameter.SwitchingPoint('LeftRight');
    end

    methods
        function obj=MflHysteresis(varargin)
            obj=setAlgorithmParameters(obj,varargin);
        end

        function obj=set.SwitchingPoint(obj,value)
            obj.SwitchingPoint=obj.SwitchingPoint.setAP(value);
        end

    end
end

