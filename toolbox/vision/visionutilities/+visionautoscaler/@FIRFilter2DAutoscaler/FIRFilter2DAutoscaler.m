


classdef FIRFilter2DAutoscaler<visionautoscaler.VIPBlocksetAutoscaler











    methods
        pathItems=getPathItems(h,blkObj)
        pathItems=getPortMapping(h,blkObj,inportIdx,outportIdx)
        maskSignednessAutoFlag=maskSignednessAuto(h,blkObj,pathItem)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj)
    end


    methods(Hidden)
        sharedLists=gatherSharedDT(h,blkObj)
        [maskSignValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)
    end

end

