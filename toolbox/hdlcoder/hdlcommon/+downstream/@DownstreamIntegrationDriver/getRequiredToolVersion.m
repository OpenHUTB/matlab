function requiredToolVersionList=getRequiredToolVersion(obj,boardName)



    if isIPWorkflow(obj)
        [isInList,hP]=obj.hIP.isInIPPlatformList(boardName);
    else
        if isempty(obj.hAvailableBoardList)
            requiredToolVersionList='';
            return
        end
        [isInList,hP]=obj.hAvailableBoardList.isInBoardList(boardName);
    end
    if isInList
        requiredToolVersionList=hP.RequiredToolVersion;
    else
        requiredToolVersionList='';
    end
end
