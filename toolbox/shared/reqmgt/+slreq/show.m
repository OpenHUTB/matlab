




























function show(targetInfo)

    if~isstruct(targetInfo)
        error(message('Slvnv:slreq:StructureMissingRequiredFields','.domain','.artifact'));
    end



    if~isfield(targetInfo,'domain')||isempty(targetInfo.domain)
        error(message('Slvnv:slreq_uri:InputFieldValueMissing','domain'));
    else
        domain=targetInfo.domain;
    end

    adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(domain);
    if isempty(adapter)
        error(message('Slvnv:rmi:navigate:TargetTypeNotRegistered',domain));
    end

    if isfield(targetInfo,'artifact')&&~isempty(targetInfo.artifact)
        artifact=targetInfo.artifact;
    elseif isfield(targetInfo,'artifactUri')&&~isempty(targetInfo.artifactUri)
        artifact=targetInfo.artifactUri;
    else
        error(message('Slvnv:slreq_uri:InputFieldValueMissing','artifact'));
    end



    if strcmp(domain,'linktype_rmi_slreq')
        if isfield(targetInfo,'sid')
            id=sprintf('#%d',targetInfo.sid);
        elseif~isfield(targetInfo,'id')
            error(message('Slvnv:slreq_uri:InputFieldValueMissing','sid/id'));
        else
            id=targetInfo.id;
        end
        reference='standalone';
    else
        if~isfield(targetInfo,'id')
            error(message('Slvnv:slreq_uri:InputFieldValueMissing','id'));
        else
            id=targetInfo.id;
            if isfield(targetInfo,'parent')&&~isempty(targetInfo.parent)


                id=slreq.utils.getLongIdFromShortId(targetInfo.parent,id);
            end
        end
        reference='';
    end


    adapter.select(artifact,id,reference);

end



