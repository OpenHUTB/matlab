function actionRefreshInterfaceTable(taskobj)


    mdladvObj=taskobj.MAObj;
    system=mdladvObj.System;


    modelName=bdroot(system);
    hDriver=hdlmodeldriver(modelName);


    hDI=hDriver.DownstreamIntegrationDriver;

    try
        utilReloadInterfaceTable(mdladvObj,hDI);
    catch ME

        utilUpdateInterfaceTable(mdladvObj,hDI);

        hf=errordlg(ME.message,'Error','modal');

        set(hf,'tag','HDL Workflow Advisor error dialog');
        setappdata(hf,'MException',ME);


        uiwait(hf);
    end

end