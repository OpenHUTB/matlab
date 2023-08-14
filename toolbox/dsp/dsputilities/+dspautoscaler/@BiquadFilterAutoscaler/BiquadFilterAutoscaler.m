classdef BiquadFilterAutoscaler<dvautoscaler.DspEntityAutoscaler












    methods
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        [signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)
        pathItems=getPathItems(h,blkObj)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj);
    end


    methods(Hidden)
        associateRecords=gatherAssociatedParam(h,blkObj)
    end

end

