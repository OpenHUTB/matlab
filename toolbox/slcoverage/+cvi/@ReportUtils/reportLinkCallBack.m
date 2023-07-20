function reportLinkCallBack(slsfId)
    modelcovId=cv('get',slsfId,'.modelcov');
    baseReportName=cv('get',modelcovId,'.currentDisplay.baseReportName');
    if isempty(baseReportName)
        return;
    end
    ref=sprintf('%s#refobj%d',baseReportName,slsfId);
    cvprivate('local_browser_mgr','displayFile',ref);

