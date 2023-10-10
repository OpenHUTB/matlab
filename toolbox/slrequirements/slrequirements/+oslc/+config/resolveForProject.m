function[config,wantedId]=resolveForProject(projName,wantedConfigUri)

    slashPos=find(wantedConfigUri=='/');
    if isempty(slashPos)
        wantedId=wantedConfigUri;
    else
        wantedId=wantedConfigUri(slashPos(end)+1:end);
    end
    config=slreq.dngGetProjectConfig('project',projName,'id',wantedId);
end



