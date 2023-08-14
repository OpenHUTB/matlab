classdef Trigonometry<coder.algorithm.parameterset.AlgorithmParameterSet




    properties(Hidden,Dependent,SetAccess=public,GetAccess=private)

    end

    properties(SetAccess=public,GetAccess=public)
        AngleUnit=coder.algorithm.parameter.AngleUnit({'radian','revolution'});
        InterpMethod=coder.algorithm.parameter.TrigInterpMethod({'Linear point-slope','Flat'});
    end

    methods
        function obj=Trigonometry(varargin)
            obj=setAlgorithmParameters(obj,varargin);
        end

        function obj=set.AngleUnit(obj,value)
            obj.AngleUnit=obj.AngleUnit.setAP(value);
        end

        function obj=set.InterpMethod(obj,value)
            obj.InterpMethod=obj.InterpMethod.setAP(value);
        end
    end
end

