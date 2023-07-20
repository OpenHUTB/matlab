function err=getArtifactErrors(obj)

    err=struct('Address',{},'UUID',{},'ErrorId',{},'ErrorMessage',{});

    as=alm.internal.ArtifactService.get(obj.ProjectPath);
    g=as.getGraph();
    a=g.getAllArtifacts();
    las=[a.LastAnalysisStatus];
    idx=(las~=alm.AnalysisStatusType.NONE&las~=alm.AnalysisStatusType.SUCCESS);
    errorArtifacts=a(idx);

    for N=1:numel(errorArtifacts)
        err(end+1).Address=errorArtifacts(N).Address;%#ok<AGROW>
        err(end).UUID=errorArtifacts(N).UUID;
        err(end).ErrorId=char(errorArtifacts(N).LastAnalysisStatus);
        err(end).ErrorMessage=errorArtifacts(N).LastAnalysisInfo;
    end

end