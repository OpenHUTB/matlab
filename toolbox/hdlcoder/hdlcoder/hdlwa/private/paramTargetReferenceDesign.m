function paramTargetReferenceDesign(taskobj)




    mdladvObj=taskobj.MAObj;


    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;


    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    rfNameOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAReferenceDesign'));
    rfVersionOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWARDToolVersion'));
    rfIgnoreOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWARDToolVersionIgnore'));


    try
        updateParameterName='';
        if~strcmp(rfNameOption.Value,hDI.hIP.getReferenceDesign)
            updateParameterName='rdname';
            hDI.hIP.setReferenceDesign(rfNameOption.Value);

            hdlwa.utilUpdateRDParameterTable(mdladvObj,hDI);

            utilCleanTargetInterfaceTable(mdladvObj,hDI);
        elseif~strcmp(rfVersionOption.Value,hDI.hIP.getRDToolVersion)
            updateParameterName='rdver';
            hDI.hIP.setRDToolVersion(rfVersionOption.Value);

            hdlwa.utilUpdateRDParameterTable(mdladvObj,hDI);

            utilCleanTargetInterfaceTable(mdladvObj,hDI);
        elseif~strcmp(rfIgnoreOption.Value,hDI.hIP.getIgnoreRDToolVersionMismatch)
            hDI.hIP.setIgnoreRDToolVersionMismatch(rfIgnoreOption.Value);
        end
    catch ME

        hdlwa.utilUpdateRDParameterTable(mdladvObj,hDI);

        hf=errordlg(ME.message,'Error','modal');

        set(hf,'tag','HDL Workflow Advisor error dialog');
        setappdata(hf,'MException',ME);


        uiwait(hf);


        hMAExplorer=mdladvObj.MAExplorer;
        if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
            currentDialog=hMAExplorer.getDialog;
            if strcmpi(updateParameterName,'rdname')
                currentDialog.setWidgetValue('InputParameters_1',getIndexNumber(hDI.hIP.getReferenceDesign,hDI.hIP.getReferenceDesignAll));
            elseif strcmpi(updateParameterName,'rdver')
                currentDialog.setWidgetValue('InputParameters_2',getIndexNumber(hDI.hIP.getRDToolVersion,hDI.hIP.getRDToolVersionAll));
            end
        end
    end

    hDI.saveRDSettingToModel(hModel,hDI.hIP.getReferenceDesign);

    currentWorkflow=hDI.get('Workflow');
    if hDI.hWorkflowList.isInWorkflowList(currentWorkflow)

        hWorkflow=hDI.hWorkflowList.getWorkflow(currentWorkflow);
        hWorkflow.hdlwa_utilAdjustTargetReferenceDesign(mdladvObj,hDI);
    else

        utilAdjustTargetReferenceDesign(mdladvObj,hDI);
    end

end


function index=getIndexNumber(name,list)

    index=0;
    for ii=1:length(list)
        if strcmpi(name,list{ii})
            index=ii-1;
        end
    end

end

