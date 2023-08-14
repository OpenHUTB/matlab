classdef(Abstract)DBUnitToSolutionAdapter<handle




    methods(Abstract)
        [solution,diagnostic]=createSolution(this,dbUnit,problemDefinition,options,dataBase);
    end
end


