

function isMatlabFunction=isParentMatlabFunctionBlock(blkObj)

    parentHdl=blkObj.Parent;
    parentObj=get_param(parentHdl,'Object');
    isMatlabFunction=strcmpi(parentObj.Type,'Block')&&...
    slci.internal.isMatlabFunctionBlock(parentObj);


end
