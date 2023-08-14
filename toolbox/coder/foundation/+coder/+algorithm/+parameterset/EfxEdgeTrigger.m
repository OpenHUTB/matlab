classdef EfxEdgeTrigger<coder.algorithm.parameterset.AlgorithmParameterSet

    properties(Hidden,Dependent,SetAccess=public,GetAccess=private)

    end

    properties(SetAccess=public,GetAccess=public)
        TriggerType=coder.algorithm.parameter.TriggerType('rising');
    end

    methods
        function obj=EfxEdgeTrigger(varargin)
            obj=setAlgorithmParameters(obj,varargin);
        end

        function obj=set.TriggerType(obj,value)
            obj.TriggerType=obj.TriggerType.setAP(value);
        end

    end
end

