function paramTargetInterface(taskobj)



    mdladvObj=taskobj.MAObj;


    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;


    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    execModeOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputFPGAExecutionMode'));
    testPointOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:hdlglblsettingsEnableTestpoints'));


    try
        updateParameterName='';
        if~strcmp(execModeOption.Value,hDI.get('ExecutionMode'))
            updateParameterName='execmode';
            hDI.set('ExecutionMode',execModeOption.Value);


            utilUpdateInterfaceTable(mdladvObj,hDI);
        elseif~isequal(testPointOption.Value,hDI.isTestPointEnabledOnModel)
            updateParameterName='testpoint';



            testPointValueOld=hDI.isTestPointEnabledOnModel;
            testPointValueNew=testPointOption.Value;
            hDI.saveTestPointSettingToModel(hModel,testPointValueNew);


            utilReloadInterfaceTable(mdladvObj,hDI);
        end

    catch ME

        utilUpdateInterfaceTable(mdladvObj,hDI);

        hf=errordlg(ME.message,'Error','modal');

        set(hf,'tag','HDL Workflow Advisor error dialog');
        setappdata(hf,'MException',ME);


        uiwait(hf);


        hMAExplorer=mdladvObj.MAExplorer;
        if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
            currentDialog=hMAExplorer.getDialog;
            if strcmpi(updateParameterName,'execmode')
                currentDialog.setWidgetValue('InputParameters_1',getIndexNumber(hDI.get('ExecutionMode'),hDI.set('ExecutionMode')));
            elseif strcmpi(updateParameterName,'testpoint')
                hDI.saveTestPointSettingToModel(hModel,testPointValueOld);
                currentDialog.setWidgetValue('InputParameters_3',hDI.isTestPointEnabledOnModel);
                utilReloadInterfaceTable(mdladvObj,hDI);
            end
        end
    end

    hDI.saveSyncModeSettingToModel(system,hDI.get('ExecutionMode'));

    utilAdjustExecutionMode(mdladvObj,hDI);
    utilAdjustTestPoints(mdladvObj,hDI);

    utilAdjustGenerateAXISlave(mdladvObj,hDI);

    utilAdjustGenerateIPCore(mdladvObj,hDI);



    taskobj.reset;

end


function index=getIndexNumber(name,list)

    index=0;
    for ii=1:length(list)
        if strcmpi(name,list{ii})
            index=ii-1;
        end
    end

end

