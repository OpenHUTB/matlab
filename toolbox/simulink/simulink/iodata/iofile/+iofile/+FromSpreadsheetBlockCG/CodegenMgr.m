function CodegenMgr(blockH)




    modelH=bdroot(blockH);
    modelName=get_param(modelH,'Name');
    tmp=coder.internal.ModelCodegenMgr.getInstance(modelName);
    tmp.BuildInfo.addSysLibs('mwsl_simtarget_instrumentation','','fromspreadsheetblock');
end

