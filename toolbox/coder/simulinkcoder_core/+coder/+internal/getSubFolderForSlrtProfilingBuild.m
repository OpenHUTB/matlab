function lCodeInstrObjFolder=getSubFolderForSlrtProfilingBuild






    lCodeCoverageSpec=[];

    lCodeExecutionProfilingTop=true;


    modelRefsAll={};
    protectedModelRefs={};
    modelsWithProfiling={};
    lTopModel='';
    lIsSilAndPws=false;

    lCodeInstrInfo=coder.internal.slCreateCodeInstrBuildArgs...
    (lTopModel,...
    lIsSilAndPws,...
    lCodeCoverageSpec,...
    lCodeExecutionProfilingTop,...
    modelsWithProfiling,...
    modelRefsAll,...
    protectedModelRefs);

    lCodeInstrObjFolder='';

    if~isempty(lCodeInstrInfo)
        lCodeInstrObjFolder=lCodeInstrInfo.getInstrObjFolder;
    end
