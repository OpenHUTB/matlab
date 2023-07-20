function actionRefreshTool(taskobj)


    mdladvObj=taskobj.MAObj;
    system=mdladvObj.System;


    hModel=bdroot(system);
    hdriver=hdlmodeldriver(hModel);


    hDI=hdriver.DownstreamIntegrationDriver;


    hDI.refreshToolList;


    utilAdjustTargetDevice(mdladvObj,hDI);


    utilCleanTargetInterfaceTable(mdladvObj,hDI);


    utilAdjustWorkflowParameter(mdladvObj,hDI);


    taskobj.reset;

end
