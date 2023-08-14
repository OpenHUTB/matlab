classdef PyramidAutoscaler<visionautoscaler.VIPBlocksetAutoscaler










    methods
        pathItems=getPathItems(h,blkObj)
        pathItems=getPortMapping(h,blkObj,inportIdx,outportIdx)
    end


    methods(Hidden)
        sharedLists=gatherSharedDT(h,blkObj)
        [maskSignValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)
    end

end

