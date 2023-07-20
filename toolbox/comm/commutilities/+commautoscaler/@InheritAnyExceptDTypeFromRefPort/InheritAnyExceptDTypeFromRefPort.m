classdef InheritAnyExceptDTypeFromRefPort<dvautoscaler.SPCBlocksetAutoscaler




    methods
        comments=checkComments(ea,blkObj,pathItem)
        pv=getSettingStrategies(h,blkObj,pathItem,proposedDT)
        sharedLists=gatherSharedDT(h,blkObj)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
    end

end


