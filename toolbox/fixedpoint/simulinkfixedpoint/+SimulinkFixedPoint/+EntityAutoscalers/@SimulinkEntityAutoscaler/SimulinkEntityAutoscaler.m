classdef SimulinkEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.AbstractEntityAutoscaler




    methods
        comment=checkComments(h,blkObj,pathItem)
        pv=getSettingStrategies(ea,blkObj,pathItem,proposedDT)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
        res=getBlockMaskTypeAttributes(h,blkObj,pathItem)
        [designMin,designMax,compiledDT,removeResult]=getModelCompiledDesignRange(h,blkObj,blkPathItem)
        pathItems=getPathItems(h,blkObj)
        pathItems=getPortMapping(h,blkObj,inportNum,outportNum)
        curListPorts=hShareDTSpecifiedPorts(h,blkObj,inportSet,outportSet)
        [isForBlkParam,blkParamName]=isPathItemForBlockParam(h,srcBlk,pathItem)
    end


    methods(Hidden)
        associateRecords=gatherAssociatedParam(h,blkObj)
        [minV,maxV]=gatherDesignMinMax(h,blkObj,pathItem)
        sharedLists=gatherSharedDT(h,blkObj)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        actualSrcBlkObj=getActualSrcBlkObj(h,blkObj)
        actualSrcIDs=getActualSrcIDs(h,blkObj)
    end

end


