classdef SPCSgnSameAsInputAutoscaler<dvautoscaler.DspEntityAutoscaler












    methods
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        [signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)
        signednessStr=getInportSignednessString(h,blkObj)
    end

end


