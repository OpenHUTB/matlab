classdef BinaryPointScaling<DataTypeOptimization.DimensionalityReductionStrategies.DimensionalityReductionStrategy






    properties(Hidden,Constant)
        binaryPointSAF=1;
        binaryPointBias=0;
    end

    methods
        function solution=processSolution(this,solution,problemPrototype,~)


            for dIndex=1:length(problemPrototype.dv)
                problemPrototype.dv(dIndex).definitionDomain.slopeAdjustmentFactor=this.binaryPointSAF;
                problemPrototype.dv(dIndex).definitionDomain.bias=this.binaryPointBias;
            end

        end
    end

end