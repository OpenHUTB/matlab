function checkDisconnectedDividerBlocks(model,checkobj)










    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(model);
    SLStudio.Utils.RemoveHighlighting(model)





...
...
...
...
...
...
...
...
...
...
...
...


    mdlh=get_param(model,'Handle');
    [status,dcblks]=helperDisconnectedDividerBlocks(mdlh,'findblocks');
    switch status
    case 'passed'
        ElementResults=ModelAdvisor.ResultDetail;
        ElementResults.IsInformer=true;
        ElementResults.Description=DAStudio.message(...
        'simrf:advisor:DisconnectedDividerBlocks_ResultsDescription');
        ElementResults.Status=DAStudio.message(...
        'simrf:advisor:DisconnectedDividerBlocks_ResultsStatusPass');
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
    case 'nolicense'
        ElementResults=ModelAdvisor.ResultDetail;
        ElementResults.Description=DAStudio.message(...
        'simrf:advisor:CheckIncomplete');
        ElementResults.Status=DAStudio.message(...
        'simrf:advisor:DisconnectedDividerBlocks_NoLicenseForCheck');
        mdladvObj.setCheckResultStatus(false);
        mdladvObj.setActionEnable(false);
    case 'failed'
        for idx=numel(dcblks):-1:1
            ElementResults(1,idx)=ModelAdvisor.ResultDetail;
        end
        for idx=1:numel(ElementResults)
            ModelAdvisor.ResultDetail.setData(ElementResults(idx),...
            'SID',dcblks(idx));
            ElementResults(idx).Description=DAStudio.message(['simrf:',...
            'advisor:DisconnectedDividerBlocks_ResultsDescription']);
            ElementResults(idx).Status=DAStudio.message(['simrf:',...
            'advisor:DisconnectedDividerBlocks_ResultsStatusFail']);
            ElementResults(idx).RecAction=DAStudio.message(['simrf:',...
            'advisor:DisconnectedDividerBlocks_ResultsRecAction']);
        end
        mdladvObj.setCheckResultStatus(false);
        mdladvObj.setActionEnable(true);
    case 'unknownerror'
        ElementResults=ModelAdvisor.ResultDetail;
        ElementResults.Description=DAStudio.message(...
        'simrf:advisor:CheckIncomplete');
        ElementResults.Status=DAStudio.message(...
        'simrf:advisor:DisconnectedDividerBlocks_ErrorRunningCheck');
        mdladvObj.setCheckResultStatus(false);
        mdladvObj.setActionEnable(false);
    end


    checkobj.setResultDetails(ElementResults);
end