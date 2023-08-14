


classdef BlobAutoscaler<visionautoscaler.VIPBlocksetAutoscaler










    methods
        pathItems=getPathItems(h,blkObj)
        pathItems=getPortMapping(h,blkObj,inportIdx,outportIdx)
        [hasDTConstraints,DTConstraintsSet]=gatherDTConstraints(h,blkObj);
    end


    methods(Hidden)
        [maskSignValStr,wlValueStr,flValueStr,specifiedDTStr,flDlgStr,modeDlgStr,wlDlgStr]=getDataTypeInfoForPathItem(h,blkObj,pathItem)
    end

end

