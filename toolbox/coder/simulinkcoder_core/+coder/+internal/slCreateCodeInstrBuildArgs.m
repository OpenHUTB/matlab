function lCodeInstrInfo=slCreateCodeInstrBuildArgs...
    (lModuleName,...
    isSILAndPWS,...
    lCodeCoverageSpec,...
    lCodeExecutionProfilingTop,...
    modelsWithProfiling,...
    modelRefsAll,...
    protectedModelRefs)







    lCodeInstrSpecs={};

    if isSILAndPWS

        lCodeInstrSpecs{end+1}=coder.internal.CodeInstrSpecPWS;
    end
    if~isempty(lCodeCoverageSpec)
        lCodeInstrSpecs{end+1}=lCodeCoverageSpec;
    end


    if Simulink.ModelReference.ProtectedModel.protectingModel(lModuleName)







        createInstrumentedFolder=false;
    else
        createInstrumentedFolder=lCodeExecutionProfilingTop;
    end
    if createInstrumentedFolder
        lCodeInstrSpecs{end+1}=...
        coder.internal.CodeInstrSpecExecTime...
        (modelsWithProfiling);
    end

    lCodeInstrInfo=coder.internal.CodeInstrBuildArgs...
    .getCodeInstrBuildArgs...
    (lModuleName,...
    modelRefsAll,...
    protectedModelRefs,...
    lCodeInstrSpecs);
