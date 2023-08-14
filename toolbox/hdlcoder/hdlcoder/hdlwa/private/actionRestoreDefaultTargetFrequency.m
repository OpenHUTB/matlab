function actionRestoreDefaultTargetFrequency(taskobj)




    mdladvObj=taskobj.MAObj;


    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;


    hMAExplorer=mdladvObj.MAExplorer;
    if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
        currentDialog=hMAExplorer.getDialog;
        currentDialog.apply;
    end




    defaultFreq=hDI.getDefaultTargetFrequency;
    hDI.setTargetFrequency(defaultFreq);

    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    targetFreq=inputParams{1};
    targetFreq.Value=num2str(defaultFreq);

    taskobj.reset;
end