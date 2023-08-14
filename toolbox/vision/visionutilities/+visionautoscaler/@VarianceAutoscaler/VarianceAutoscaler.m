classdef VarianceAutoscaler<dvautoscaler.SPCSgnSameAsInputAutoscaler










    methods
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem)
        pathItems=getPathItems(h,blkObj)
        pathItems=getPortMapping(h,blkObj,inportNum,outportNum)
    end

    methods(Hidden)
        [signValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)
    end

end


