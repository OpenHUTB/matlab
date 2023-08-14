


classdef LookupNDDirectEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SimulinkEntityAutoscaler










    methods
        res=getBlockMaskTypeAttributes(h,blkObj,pathItem)
        pathItems=getPathItems(h,blkObj)
        [isForBlkParam,blkParamName]=isPathItemForBlockParam(~,blkObj,pathItem)
    end


    methods(Hidden)
        associateRecords=gatherAssociatedParam(h,blkObj)
        [minV,maxV]=gatherDesignMinMax(h,blkObj,PathItems)
        sharedLists=gatherSharedDT(h,blkObj)
    end

end


