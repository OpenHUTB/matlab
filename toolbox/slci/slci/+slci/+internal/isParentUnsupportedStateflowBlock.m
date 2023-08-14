


function unsupportedSf=isParentUnsupportedStateflowBlock(blkObj)

    parentHdl=blkObj.Parent;
    if strcmpi(get_param(parentHdl,'Type'),'Block')
        unsupportedSf=slci.internal.isUnsupportedStateflowBlock(parentHdl);
    else
        unsupportedSf=false;
    end

end
