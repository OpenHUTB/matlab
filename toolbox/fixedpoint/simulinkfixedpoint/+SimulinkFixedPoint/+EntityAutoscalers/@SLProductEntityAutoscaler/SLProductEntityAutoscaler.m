classdef SLProductEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SimulinkEntityAutoscaler


    methods
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(this,blockObject)
        [pathItems]=getPathItems(this,blockObject)
        [sharedLists]=gatherSharedDT(this,blockObject)
        [res]=getBlockMaskTypeAttributes(this,blockObject,pathItem)
    end
end