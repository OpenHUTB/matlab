classdef Resize2DAutoscaler<visionautoscaler.VIPBlocksetAutoscaler











    methods
        pathItems=getPathItems(h,blkObj)
        pathItems=getPortMapping(h,blkObj,inportIdx,outportIdx)
        [horizFactor,vertFactor]=getXYresizeFactor(h,resize)
    end


    methods(Hidden)
        resizeWithoutTable=ResizeWithoutTable(h,blkObj)
        sharedLists=gatherSharedDT(h,blkObj)
        [maskSignValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)
        hideAccProdFixptTabParams=hideAccProdFixptTabParameters(h,blkObj)
        hideFixptTabParams=hideFixptTabParameters(h,blkObj)
        roi_exist=roi_exists(h,blkObj)
    end

end

