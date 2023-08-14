classdef MedianFilter2DAutoscaler<visionautoscaler.VIPBlocksetAutoscaler










    methods
        pathItems=getPathItems(h,blkObj)
        pathItems=getPortMapping(h,blkObj,inportIdx,outportIdx)
    end


    methods(Hidden)
        sharedLists=gatherSharedDT(h,blkObj)
        [maskSignValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)
        hasFixptTabParams=hasFixptTabParameters(h,blkObj)
    end

end

