function navigateFromLinkToTestResult(linkFullID)




    link=slreq.utils.getLinkObjFromFullID(linkFullID);
    if~isempty(link)
        resultsManager=slreq.data.ResultManager.getInstance();
        resultsManager.navigate(link);
    else



    end
end