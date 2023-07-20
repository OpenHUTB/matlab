function harnessOwnerName=getHarnessOwnerName(mdlName,harnessID)



    harnessOwnerName='';
    harnessInfo=sltest.harness.find(mdlName,'UUID',harnessID);
    if isempty(harnessInfo)
        harnessInfo=sltest.harness.find(mdlName,'Name',harnessID);
    end

    if(~isempty(harnessInfo))
        harnessOwnerName=harnessInfo.ownerFullPath;
    end
end
