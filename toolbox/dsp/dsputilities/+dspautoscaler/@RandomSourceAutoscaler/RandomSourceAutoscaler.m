classdef RandomSourceAutoscaler<SimulinkFixedPoint.EntityAutoscalers.SimulinkEntityAutoscaler




    methods
        comments=checkComments(ea,blkObj,pathItem)
        pv=getSettingStrategies(h,blkObj,pathItem,proposedDT)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
    end

end




