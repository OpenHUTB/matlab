function harnessName=getHarnessName(mdlName,harnessID)



    harnessName='';
    try
        harnessInfo=sltest.harness.find(mdlName,'UUID',harnessID);
    catch

        harnessInfo=sltest.harness.find(mdlName,'Name',harnessID);
    end
    if(~isempty(harnessInfo))
        harnessName=harnessInfo.Name;
    end
end
