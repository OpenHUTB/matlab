function navigateFromReference(refObj)






















    [projName,baseUrl]=oslc.Project.currentProject();
    if isempty(projName)
        error(message('Slvnv:oslc:ConfigContextUpdateNoProject'));
    end




    registeredType=rmi.linktype_mgr('resolveByRegName','linktype_rmi_oslc');
    if isempty(registeredType)
        rmi.loadLinktype('oslc.linktype_rmi_oslc');
        registeredType=rmi.linktype_mgr('resolveByRegName','linktype_rmi_oslc');
    end





    if isa(refObj.parent,'slreq.ReqSet')
        refObj=refObj.getFirstChild();
        if isempty(refObj)


            registeredType.NavigateFcn(baseUrl,'');
            return;
        end
    end



    if isa(refObj,'slreq.Reference')
        artifactId=refObj.ArtifactId;
        if isempty(artifactId)
            artifactId=refObj.CustomId;
        end
    else


        artifactId=refObj.customId;
    end


    dngReq=oslc.getReqItem(artifactId);
    if isempty(dngReq)
        error(message('Slvnv:reqmgt:NotFoundIn',artifactId,projName));
    else
        registeredType.NavigateFcn(baseUrl,dngReq.resource);
    end
end

