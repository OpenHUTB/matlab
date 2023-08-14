


classdef ModelReferenceEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SimulinkEntityAutoscaler









    methods
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
    end


    methods(Hidden)
        crossBoundaryRec=gatherMdlRefBoundarySharedDT(h,blkObj,PathItem)
        sharedLists=gatherSharedDT(h,blkObj)
    end

end


