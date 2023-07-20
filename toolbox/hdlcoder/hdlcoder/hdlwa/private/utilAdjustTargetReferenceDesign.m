function utilAdjustTargetReferenceDesign(mdladvObj,hDI)





    if~hDI.showReferenceDesignTasks
        return;
    end


    hdlwa.utilAdjustTargetReferenceDesignTaskOnly(mdladvObj,hDI);


    if hDI.showExecutionMode
        utilAdjustExecutionMode(mdladvObj,hDI);
    end


    utilAdjustTargetFrequency(mdladvObj,hDI);


    utilAdjustGenerateAXISlave(mdladvObj,hDI);


    utilAdjustGenerateIPCore(mdladvObj,hDI);


    utilAdjustEmbeddedProject(mdladvObj,hDI);


    utilAdjustEmbeddedModelGen(mdladvObj,hDI);


    utilAdjustEmbeddedSystemBuild(mdladvObj,hDI);


    utilAdjustEmbeddedDownload(mdladvObj,hDI);

end

