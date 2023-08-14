function utilAdjustWorkflowParameter(mdladvObj,hDI)





    currentWorkflow=hDI.get('Workflow');
    if hDI.hWorkflowList.isInWorkflowList(currentWorkflow)
        hWorkflow=hDI.hWorkflowList.getWorkflow(currentWorkflow);
        hWorkflow.hdlwa_utilAdjustWorkflowParameter(mdladvObj,hDI);
        return;
    end

    isIPCoreGen=hDI.isIPCoreGen;


    utilAdjustTargetReferenceDesign(mdladvObj,hDI);


    utilAdjustExecutionMode(mdladvObj,hDI);

    hDI.updateCodegenAndPrjDir;


    system=mdladvObj.System;
    sobj=get_param(bdroot(system),'Object');
    configSet=sobj.getActiveConfigSet;
    hObj=gethdlcconfigset(configSet);
    hModel=bdroot(system);

    curRtlDir=hdlget_param(hModel,'TargetDirectory');
    if~strcmp(curRtlDir,hDI.getFullHdlsrcDir)
        hObj.getCLI.TargetDirectory=hDI.getFullHdlsrcDir;
        hdlset_param(hModel,'TargetDirectory',hDI.getFullHdlsrcDir);
    end

    if~hDI.isToolEmpty&&~hDI.isFILWorkflow
        hDI.setProjectPath(hDI.getFullFPGADir);
    end


    utilAdjustGenerateHDLCode(mdladvObj,hDI);


    utilAdjustMapping(mdladvObj,hDI);
    utilAdjustDetermineBASourceOptions(mdladvObj,hDI);


    utilAdjustCreateProject(mdladvObj,hDI);



    if isIPCoreGen
        utilAdjustTestPoints(mdladvObj,hDI);
        utilAdjustGenerateAXISlave(mdladvObj,hDI);
        utilAdjustGenerateIPCore(mdladvObj,hDI);
    end

end


