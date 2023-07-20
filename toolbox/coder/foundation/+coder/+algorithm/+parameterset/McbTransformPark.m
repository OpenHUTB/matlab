classdef McbTransformPark<coder.algorithm.parameterset.AlgorithmParameterSet



    properties(Hidden,Dependent,SetAccess=public,GetAccess=private)

    end

    properties(SetAccess=public,GetAccess=public)
        AxisAlignment=coder.algorithm.parameter.AxisAlignment('dAxis');
    end

    methods
        function obj=McbTransformPark(varargin)
            obj=setAlgorithmParameters(obj,varargin);
        end

        function obj=set.AxisAlignment(obj,value)
            obj.AxisAlignment=obj.AxisAlignment.setAP(value);
        end

    end
end

