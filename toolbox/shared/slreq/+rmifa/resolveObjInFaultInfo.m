function obj=resolveObjInFaultInfo(idStr)







    if rmifa.isLinkingForFaultObjAllowed(idStr)
        obj=idStr;
        return;
    end

    prefInd=strfind(idStr,rmifa.itemIDPref());
    mdlName=idStr(1:prefInd-1);
    itemID=idStr(prefInd:end);
    try
        [obj,~]=rmifa.getFaultInfoObj(mdlName,itemID);
    catch ex %#ok<NASGU>
        obj=[];
        return;
    end
end
