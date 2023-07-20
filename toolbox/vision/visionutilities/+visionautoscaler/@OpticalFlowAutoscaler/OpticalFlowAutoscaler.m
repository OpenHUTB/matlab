classdef OpticalFlowAutoscaler<visionautoscaler.VIPBlocksetAutoscaler










    methods
        pathItems=getPathItems(h,blkObj)
        pathItems=getPortMapping(h,blkObj,inportIdx,outportIdx)
    end


    methods(Hidden)
        [maskSignValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)
    end

end

