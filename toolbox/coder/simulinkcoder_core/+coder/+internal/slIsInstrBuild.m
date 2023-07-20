function isInstrBuild=slIsInstrBuild...
    (lModuleName,...
    isSILAndPWS,...
    lCodeCoverageSpec,...
    lCodeExecutionProfilingTop,...
    lCodeStackProfilingTop,...
    lCodeProfilingWCETAnalysis)





    isInstrBuild=false;


    if isSILAndPWS
        isInstrBuild=true;
    end

    if~isempty(lCodeCoverageSpec)
        objFolder=getInstrObjFolders(lCodeCoverageSpec,{lModuleName},{});
        if~isempty(objFolder{1})
            isInstrBuild=true;
        end
    end


    if Simulink.ModelReference.ProtectedModel.protectingModel(lModuleName)







        createInstrumentedFolderForProfiling=false;
    else
        createInstrumentedFolderForProfiling=...
        lCodeExecutionProfilingTop||lCodeProfilingWCETAnalysis||lCodeStackProfilingTop;
    end
    if createInstrumentedFolderForProfiling
        isInstrBuild=true;
    end

