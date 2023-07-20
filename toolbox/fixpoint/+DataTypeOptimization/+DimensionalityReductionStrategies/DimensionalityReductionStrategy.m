classdef(Abstract)DimensionalityReductionStrategy





    methods(Abstract)
        solution=processSolution(this,solution,problemPrototype,evaluationService)
    end
end

