function success=promptToRemoveStaleAttributeOption(dataReq,attributeToRemove,exMessage)
    response=questdlg({exMessage,...
    getString(message('Slvnv:slreq_import:AttributeRequired',attributeToRemove)),...
    getString(message('Slvnv:slreq_import:AttributeCleanup'))},...
    getString(message('Slvnv:slreq_import:UnableToSyncronize')),...
    getString(message('Slvnv:slreq_import:Cleanup')),...
    getString(message('Slvnv:slreq_import:Cancel')),...
    getString(message('Slvnv:slreq_import:Cancel')));
    if~isempty(response)&&strcmp(response,getString(message('Slvnv:slreq_import:Cleanup')))
        removeAttributeFromStoredOptions(dataReq,attributeToRemove);
        success=true;
    else
        success=false;
    end
end

function removeAttributeFromStoredOptions(dataReq,attributeToRemove)
    reqSetName=dataReq.getReqSet.name;
    docName=dataReq.artifactUri;
    try
        importOptions=slreq.import.loadStoredOptions(reqSetName,docName,'');
        attributeIdx=strcmp(importOptions.attributes,attributeToRemove);
        importOptions.attributes(attributeIdx)=[];
        optionsFileName=slreq.import.impOptFile(reqSetName,docName);
        save(optionsFileName,'importOptions');
        dataReq.getReqSet.save();
    catch ex
        throwAsCaller(ex);
    end
end
