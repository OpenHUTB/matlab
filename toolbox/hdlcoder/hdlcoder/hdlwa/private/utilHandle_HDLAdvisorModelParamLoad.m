function utilHandle_HDLAdvisorModelParamLoad(system)



    mdlObj=get_param(bdroot(system),'object');
    mdladvObj=mdlObj.getModelAdvisorObj;
    model=bdroot(system);


    fh=waitbar(0,'Please wait...');


    hdriver=hdlmodeldriver(model);
    hDI=hdriver.DownstreamIntegrationDriver;

    if~hDI.getloadingFromModel
        hDI.setloadingFromModel(true);
    end


    hdlwaDriver=hdriver.getWorkflowAdvisorDriver;


    utilAdjustTargetDevice(mdladvObj,hDI);
    utilAdjustWorkflowParameter(mdladvObj,hDI);
    utilAdjustCreateProject(mdladvObj,hDI);


    if(hDI.isIPCoreGen)
        utilAdjustGenerateIPCore(mdladvObj,hDI);
        utilAdjustEmbeddedModelGen(mdladvObj,hDI);
        utilAdjustEmbeddedProject(mdladvObj,hDI);
        utilAdjustEmbeddedSystemBuild(mdladvObj,hDI);
        utilAdjustEmbeddedDownload(mdladvObj,hDI);
    elseif(hDI.isTurnkeyWorkflow||hDI.isGenericWorkflow||hDI.isSLRTWorkflow)

        utilAdjustGenerateHDLCode(mdladvObj,hDI)


        utilAdjustMapping(mdladvObj,hDI);
        utilAdjustDetermineBASourceOptions(mdladvObj,hDI);

        if(hDI.isGenericWorkflow)
            utilAdjustAnnotateModel(mdladvObj,hDI);
        end
    end

    if hDI.isTurnkeyWorkflow||hDI.isXPCWorkflow||hDI.isIPCoreGen
        if hDI.showExecutionMode
            targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.SetTargetInterfaceAndMode');
        else
            targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.SetTargetInterface');
        end

        utilUpdateInterfaceTable(mdladvObj,hDI);

        targetObj.reset;
    end


    if hDI.isGenericWorkflow||hDI.isTurnkeyWorkflow||hDI.isSLRTWorkflow||hDI.isIPWorkflow||hDI.isFILWorkflow
        utilAdjustTargetFrequency(mdladvObj,hDI)
    end

    hDI.setloadingFromModel(false);

    close(fh);

end


