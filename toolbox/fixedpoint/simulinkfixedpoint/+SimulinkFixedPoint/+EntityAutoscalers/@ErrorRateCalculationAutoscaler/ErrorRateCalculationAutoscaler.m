classdef ErrorRateCalculationAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SimulinkEntityAutoscaler



    methods
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blockObject);
        sharedLists=gatherSharedDT(h,blockObjects);
    end
end


