classdef McbTrigBlocks<coder.algorithm.parameterset.AlgorithmParameterSet



    properties(Hidden,Dependent,SetAccess=public,GetAccess=private)

    end

    properties(SetAccess=public,GetAccess=public)
        outputUnit=coder.algorithm.parameter.outputUnit('Radians');
    end

    methods
        function obj=McbTrigBlocks(varargin)
            obj=setAlgorithmParameters(obj,varargin);
        end

        function obj=set.outputUnit(obj,value)
            obj.outputUnit=obj.outputUnit.setAP(value);
        end

    end
end

