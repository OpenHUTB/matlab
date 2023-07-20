classdef CornerMetricAutoscaler<dvautoscaler.DspEntityAutoscaler




    methods
        pv=getSettingStrategies(ea,blkObj,pathItem,proposedDT)
        comments=checkComments(h,blkObj,pathItem)
        [DTConInfo,comments,paramNames]=gatherSpecifiedDT(h,blkObj,pathItem);
        pathItems=getPathItems(h,blkObj);
        pathItems=getPortMapping(h,blkObj,inportNum,outportNum);

        [maskSignValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)
    end

end


