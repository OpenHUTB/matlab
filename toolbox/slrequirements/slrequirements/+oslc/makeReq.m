function reqStruct=makeReq(req)



    reqStruct=rmi.createEmptyReqs(1);

    reqStruct.linked=true;
    reqStruct.doc=[req.queryBase,' (',req.projectName,')'];
    reqStruct.id=[req.resource,' (',req.identifier,')'];
    if strcmp(req.title,'...')

        oslc.Requirement.updateDetails(req.identifier);
    end
    reqStruct.description=req.label;
    reqStruct.reqsys='linktype_rmi_oslc';
    tag=rmi.settings_mgr('get','selectTag');
    if~isempty(tag)
        reqStruct.keywords=tag;
    end

end
