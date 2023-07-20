function discardRequirementsFile(requirementsFileName,requirementsFilePath)
    reqData=slreq.data.ReqData.getInstance();
    [~,name,ext]=fileparts(requirementsFilePath);
    switch(ext)
    case '.slreqx'
        requirementSetObj=reqData.getReqSet(requirementsFileName);
        if~isempty(requirementSetObj)
            reqData.discardReqSet(requirementSetObj);
        end
    case '.slmx'
        if contains(name,'~')
            name=regexprep(name,'~\w*$','');
        end

        linkSetObj=reqData.getLoadedLinkSetByName(name);
        lsm=slreq.linkmgr.LinkSetManager.getInstance;
        lsm.clearAllReferencesForLinkSet(linkSetObj);
        if~isempty(linkSetObj)
            reqData.discardLinkSet(linkSetObj);
        end
    end
end