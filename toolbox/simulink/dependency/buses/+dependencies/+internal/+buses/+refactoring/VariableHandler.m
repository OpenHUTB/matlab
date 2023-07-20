classdef(Abstract)VariableHandler<matlab.mixin.Heterogeneous





    properties(Abstract,Constant)

        SubType(1,1)string;
    end

    methods








        refactor(this,dependency,newElements,fileHandler);

    end
end

