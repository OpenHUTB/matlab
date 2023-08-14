function val=isCodeInstrumentationProfiling(model)





    modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(model);
    val=modelCodegenMgr.CoderTargetExecutionProfiling;
end