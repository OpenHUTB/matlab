function paramEmbeddedModelGen(taskobj)




    mdladvObj=taskobj.MAObj;


    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;


    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    swModelOption=utilGetInputParameter(inputParams,DAStudio.message('hdlcommon:workflow:HDLWASWInterfaceModel'));
    hostModelOption=utilGetInputParameter(inputParams,DAStudio.message('hdlcommon:workflow:HDLWAHostInterfaceModel'));
    hostInterfaceOption=utilGetInputParameter(inputParams,DAStudio.message('hdlcommon:workflow:HDLWAHostTargetInterfaceType'));

    if(~hDI.isShowCustomSWModelGenerationTask)
        osOption=utilGetInputParameter(inputParams,DAStudio.message('hdlcommon:workflow:HDLWAOS'));
        swScriptOption=utilGetInputParameter(inputParams,DAStudio.message('hdlcommon:workflow:HDLWASWInterfaceScript'));
    end


    try
        if~isequal(swModelOption.Value,hDI.hIP.GenerateSoftwareInterfaceModel)
            updateParameterName='model';
            hDI.hIP.GenerateSoftwareInterfaceModel=swModelOption.Value;
        end

        if~hDI.isShowCustomSWModelGenerationTask
            if~isequal(osOption.Value,hDI.hIP.getOperatingSystem)

                updateParameterName='os';
                hDI.hIP.setOperatingSystem(osOption.Value);
            elseif~isequal(hostInterfaceOption.Value,hDI.hIP.HostTargetInterface)

                updateParameterName='hostTargetInterface';
                hDI.hIP.HostTargetInterface=hostInterfaceOption.Value;




                hMAExplorer=mdladvObj.MAExplorer;
                currentDialog=hMAExplorer.getDialog;
                currentDialog.setWidgetValue('InputParameters_4',hDI.hIP.GenerateHostInterfaceModel)
            elseif~isequal(hostModelOption.Value,hDI.hIP.GenerateHostInterfaceModel)

                updateParameterName='hostmodel';
                hDI.hIP.GenerateHostInterfaceModel=hostModelOption.Value;
            elseif~isequal(swScriptOption.Value,hDI.hIP.GenerateHostInterfaceScript)

                updateParameterName='script';
                hDI.hIP.GenerateHostInterfaceScript=swScriptOption.Value;
            end
        end

    catch ME
        hf=errordlg(ME.message,'Error','modal');

        set(hf,'tag','HDL Workflow Advisor error dialog');
        setappdata(hf,'MException',ME);


        uiwait(hf);


        hMAExplorer=mdladvObj.MAExplorer;
        if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
            currentDialog=hMAExplorer.getDialog;
            if strcmpi(updateParameterName,'model')
                currentDialog.setWidgetValue('InputParameters_1',hDI.hIP.GenerateSoftwareInterfaceModel);
            elseif strcmpi(updateParameterName,'os')
                currentDialog.setWidgetValue('InputParameters_2',hDI.hIP.getOperatingSystem);
            elseif strcmpi(updateParameterName,'hostTargetInterface')
                currentDialog.setWidgetValue('InputParameters_3',hDI.hIP.getHostTargetInterface);
            elseif strcmpi(updateParameterName,'hostmodel')
                currentDialog.setWidgetValue('InputParameters_4',hDI.hIP.GenerateHostInterfaceModel);
            elseif strcmpi(updateParameterName,'script')
                currentDialog.setWidgetValue('InputParameters_5',hDI.hIP.GenerateHostInterfaceScript);


            end
        end
    end


    utilAdjustEmbeddedModelGen(mdladvObj,hDI);


