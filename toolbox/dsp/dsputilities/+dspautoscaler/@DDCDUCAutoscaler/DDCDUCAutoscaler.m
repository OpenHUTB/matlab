


classdef DDCDUCAutoscaler<dvautoscaler.SPCUniDTAutoscaler












    methods
        sharedLists=gatherSharedDT(h,blkObj)
        pathItems=getPathItems(h,blkObj)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
    end


end