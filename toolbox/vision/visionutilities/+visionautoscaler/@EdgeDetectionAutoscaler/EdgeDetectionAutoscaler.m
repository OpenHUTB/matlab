classdef EdgeDetectionAutoscaler<visionautoscaler.VIPBlocksetAutoscaler




    methods
        pv=getSettingStrategies(ea,blkObj,pathItem,proposedDT)
        comments=checkComments(h,blkObj,pathItem)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        [maskSignValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)
        pathItems=getPathItems(h,blkObj)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
    end

end


