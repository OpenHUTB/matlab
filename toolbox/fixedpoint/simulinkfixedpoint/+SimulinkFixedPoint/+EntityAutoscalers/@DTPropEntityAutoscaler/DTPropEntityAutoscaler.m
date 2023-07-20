classdef DTPropEntityAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SimulinkEntityAutoscaler




    methods
        comment=checkComments(h,blkObj,pathItem)
        pv=getSettingStrategies(ea,blkObj,pathItem,proposedDT)
        pathItems=getPathItems(h,blkObj)
        pathItems=getPortMapping(h,blkObj,inportNum,outportNum)
        sharedLists=gatherSharedDT(h,blkObj)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        isSameDT=isSameDTConfiguration(this,blkObj)
    end

end


