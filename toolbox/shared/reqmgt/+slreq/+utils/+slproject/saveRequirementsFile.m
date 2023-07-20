function saveRequirementsFile(requirementsFileName,requirementsFilePath)
    reqData=slreq.data.ReqData.getInstance();
    [~,~,ext]=fileparts(requirementsFilePath);
    switch(ext)
    case '.slreqx'
        requirementSetObj=reqData.getReqSet(requirementsFileName);
        if~isempty(requirementSetObj)
            reqData.saveReqSet(requirementSetObj);
        end
    case '.slmx'
        linkSetObj=reqData.getLinkSet(requirementsFileName);
        if~isempty(linkSetObj)
            reqData.saveLinkSet(linkSetObj);
        end
    end
end