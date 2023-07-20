function lCodeInstrRegistry=doWCETInstrumentation(lModelName,...
    lBuildDirectory,lCodeGenerationId,lInstrSrcFolder)





    profilingTraceability=load('profilingTraceability.mat');
    profTraceInfo=profilingTraceability.profTraceInfo;
    assert(profilingTraceability.lCodeGenerationId==lCodeGenerationId,...
    'Profiling data must be for the most recent build')

    lOriginalModelRef=profTraceInfo.OriginalModelRef;
    cfgTmp=Simulink.fileGenControl('getConfig');
    lWordSize=get_param(lModelName,'TargetWordSize');
    lAnchorFolder=cfgTmp.CodeGenFolder;
    lCodeFolderRelative=lBuildDirectory(length(lAnchorFolder)+2:end);
    lCodeInstrRegistry=...
    coder.profile.TimeProbeComponentRegistry(...
    get_param(lOriginalModelRef,'Name'),...
    lOriginalModelRef,...
    lWordSize,...
    [],...
    get_param(lModelName,'MaxIdLength'),...
    lCodeFolderRelative);

    numProbes=length(profTraceInfo.ProbeSites);
    newModelTraceInfo=repmat(struct('CodeName','','CallSiteSids',{},'CallSiteNames',{}),numProbes,1);

    for i=1:numProbes
        codeName=sprintf('location_%d',profTraceInfo.ProbeSites(i).TraceId);
        st.CodeName=codeName;
        st.CallSiteSids={''};
        st.CallSiteNames={codeName};
        newModelTraceInfo(i)=st;
    end
    profTraceInfo.ModelTraceInfo=newModelTraceInfo';




    lProbesToKeep=coder.profile.findUniqueProbes(profTraceInfo.ProbeSites);
    profTraceInfo.ProbeSites=profTraceInfo.ProbeSites(lProbesToKeep);
    profTraceInfo.ProbeTypes=profTraceInfo.ProbeTypes(lProbesToKeep);

    lCodeInstrRegistry.insertProbes...
    (profTraceInfo,...
    profTraceInfo.DeclarationsSite,...
    lInstrSrcFolder);
end
