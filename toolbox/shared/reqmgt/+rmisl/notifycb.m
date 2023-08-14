function notifycb(method,modelName)





    modelH=get_param(modelName,'Handle');

    switch(method)
    case 'PerspectiveHelp'
        helpview(fullfile(docroot,'slrequirements','helptargets.map'),'authorreqs_editor');
    case 'UpdateNow'
        rmidata.updateEmbeddedData(modelH);
    case 'SaveNow'
        if strcmp(get_param(modelName,'Dirty'),'on')
            save_system(modelName);
        else
            rmidata.save(modelName);
        end
        rmisl.notify(modelH,'');
    case 'ExportData'
        rmidata.updateEmbeddedData(modelH);
    case 'SaveInSLXFormat'
        modelLocation=get_param(modelH,'FileName');
        newFileName=regexprep(modelLocation,'\.mdl$','.slx');
        save_system(modelName,newFileName);
        rmidata.updateEmbeddedData(modelH);
        save_system(modelName);
    case 'UnlockLibrary'
        set_param(modelName,'lock','off')
    case 'NoLinkDependenciesHelp'
        helpview(fullfile(docroot,'slrequirements','helptargets.map'),'slproject-reqs-workflow');
    case 'NotificationOnInformationalTypeMoreInfo'
        helpview(fullfile(docroot,'slrequirements','ug','requirement-types.html'));
    case 'UpdateReqTableIncomingLinks'
        reqData=slreq.data.ReqData.getInstance();
        reqSetName=reqData.getSfReqSet(modelH);
        dataReqSet=reqData.getReqSet(reqSetName);
        if~isempty(dataReqSet)
            dataReqSet.updateIncomingLinks();
        end
    case 'DisconnectReqTableIncomingLinks'
        reqData=slreq.data.ReqData.getInstance();
        reqSetName=reqData.getSfReqSet(modelH);
        dataReqSet=reqData.getReqSet(reqSetName);
        if~isempty(dataReqSet)
            dataReqSet.disconnectIncomingLinks();
        end
    end
end

