classdef(Abstract)ParameterSpaceSampler<matlab.mixin.Heterogeneous
    properties(SetAccess=immutable)
ParameterSpace
    end

    methods
        function obj=ParameterSpaceSampler(parameterSpace)
            obj.ParameterSpace=parameterSpace;
        end
    end

    methods(Abstract)
        createDesignPoints()
        createDesignPointAtIndex(obj,index)
        getNumDesignPoints()
    end
end