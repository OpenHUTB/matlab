classdef(Abstract)XVariableValidationStrategy





    methods(Abstract)
        xVariable=validateXVariable(obj,chartData,xVariable,chartClassName)
    end
end