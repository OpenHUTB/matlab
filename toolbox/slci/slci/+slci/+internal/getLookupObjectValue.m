



function out=getLookupObjectValue(blkHandle,objName)
    out=containers.Map('KeyType','char','ValueType','any');
    try
        lutObj=slResolve(objName,blkHandle);
    catch
        return;
    end
    out=slci.internal.getValueFromLookupTableObject(lutObj,objName);
end
