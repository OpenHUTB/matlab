classdef CostEstimatorConfiguration<handle




    properties
OperatorWeights
ConfigSet
        EnableDiagnostics logical=false;
    end

    methods

        function obj=CostEstimatorConfiguration(aConfigSet)
            obj.OperatorWeights=designcostestimation.internal.OperatorsWeight2d();
            obj.ConfigSet=aConfigSet;
        end


        function setOperatorWeight(obj,aOperatorWeight)
            obj.OperatorWeights=aOperatorWeight;
        end

    end
end
