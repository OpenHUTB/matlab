function paramEmbeddedProject(taskobj)



    mdladvObj=taskobj.MAObj;


    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;

    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    objectiveOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAObjective'));
    ipcacheOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPCache'));


    try
        updateParameterName='';
        if(~strcmp(objectiveOption.Value,hDI.getObjectiveName))
            updateParameterName='objective';
            hDI.setObjectiveFromName(objectiveOption.Value);
        elseif(~strcmp(ipcacheOption.Value,hDI.hIP.getUseIPCache))
            updateParameterName='ipcache';
            hDI.hIP.setUseIPCache(ipcacheOption.Value);
        end
    catch ME
        hf=errordlg(ME.message,'Error','modal');

        set(hf,'tag','HDL Workflow Advisor error dialog');
        setappdata(hf,'MException',ME);


        uiwait(hf);


        hMAExplorer=mdladvObj.MAExplorer;
        if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
            currentDialog=hMAExplorer.getDialog;
            if strcmpi(updateParameterName,'objective')
                currentDialog.setWidgetValue('InputParameters_3',getIndexNumber(hDI.getObjectiveName,hDI.Objective.getObjectiveList));
            end
            if strcmpi(updateParameterName,'ipcache')
                currentDialog.setWidgetValue('InputParameters_4',hDI.hIP.getUseIPCache);
            end
        end
    end


    utilAdjustEmbeddedProject(mdladvObj,hDI);

end


