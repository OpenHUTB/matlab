classdef SPCUniDTIndependentOutputAutoscaler<SimulinkFixedPoint.EntityAutoscalers.AbstractEntityAutoscaler





    methods
        comment=checkComments(h,blkObj,pathItem)
        pv=getSettingStrategies(h,blkObj,pathItem,proposedDT)
        records=gatherAssociatedParam(h,blkObj)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        [outputPortIndices,outputMaxValues,outputMinValues]=getModelRequiredMinMaxOutputValues(h,blkObj)
        pathItems=getPathItems(h,blkObj)
        pathItems=getPortMapping(h,blkObj,inportNum,outportNum)
        sharedLists=gatherSharedDT(h,blkObj)
    end

end


