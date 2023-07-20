classdef DspEntityAutoscaler<dvautoscaler.SPCBlocksetAutoscaler




    methods
        comments=checkComments(ea,blkObj,pathItem)
        pv=getSettingStrategies(h,blkObj,pathItem,proposedDT)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        [signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)
        pathItems=getPathItems(h,blkObj)
        pathItems=getPathItemsForConstraints(h,blkObj)
    end

end


