function utilAdjustTargetDevice(mdladvObj,hDI)




    hdlwaDriver=hdlwa.hdlwaDriver.getHDLWADriverObj;
    targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.SetTargetDevice');


    targetInputParams=mdladvObj.getInputParameters(targetObj.MAC);
    workflowOption=targetInputParams{1};
    boardOption=targetInputParams{2};
    toolOption=targetInputParams{3};
    familyOption=targetInputParams{4};
    deviceOption=targetInputParams{5};
    packageOption=targetInputParams{6};
    speedOption=targetInputParams{7};
    folderOption=targetInputParams{8};
    boardManagerBtn=targetInputParams{10};
    toolVersionOption=targetInputParams{12};
    AllowToolVersionOption=targetInputParams{13};


    workflowOption.Entries=hDI.set('Workflow');
    boardOption.Entries=hDI.set('Board');
    toolOption.Entries=hDI.set('Tool');
    familyOption.Entries=hDI.set('Family');
    deviceOption.Entries=hDI.set('Device');
    packageOption.Entries=hDI.set('Package');
    speedOption.Entries=hDI.set('Speed');

    workflowOption.Value=hDI.get('Workflow');
    boardOption.Value=hDI.get('Board');
    toolOption.Value=hDI.get('Tool');
    familyOption.Value=hDI.get('Family');
    deviceOption.Value=hDI.get('Device');
    packageOption.Value=hDI.get('Package');
    speedOption.Value=hDI.get('Speed');
    folderOption.Value=hDI.getProjectFolder;
    toolVersionOption.Value=hDI.getToolVersion;

    system=mdladvObj.System;
    hModel=bdroot(system);

    hDI.savetargetDeviceSettingToModel(hModel,workflowOption.Value,boardOption.Value,toolOption.Value,familyOption.Value,deviceOption.Value,packageOption.Value,speedOption.Value);


    enableBoardWidget=~hDI.isGenericWorkflow;


    enableToolWidget=true;



    if hDI.isToolEmpty
        enableDeviceWidget=false;
    elseif hDI.isGenericWorkflow
        enableDeviceWidget=true;
    elseif hDI.isIPWorkflow&&hDI.isGenericIPPlatform
        enableDeviceWidget=true;
    else
        enableDeviceWidget=false;
    end



    if strcmpi(hDI.get('Tool'),'Altera Quartus II')||...
        strcmpi(hDI.get('Tool'),'Intel Quartus Pro')||...
        (strcmpi(hDI.get('Tool'),'Xilinx Vivado')&&(isempty(hDI.get('Package'))&&isempty(hDI.get('Speed'))))
        enableAlteraWidget=false;
    else

        enableAlteraWidget=true;
    end

    boardOption.Enable=enableBoardWidget;
    toolOption.Enable=enableToolWidget;
    familyOption.Enable=enableDeviceWidget;
    deviceOption.Enable=enableDeviceWidget;
    packageOption.Enable=enableDeviceWidget&&enableAlteraWidget;
    speedOption.Enable=enableDeviceWidget&&enableAlteraWidget;
    boardManagerBtn.Enable=hDI.isFILWorkflow||hDI.isTurnkeyWorkflow;


    utilUpdateGenericWorkflowWithLibrary(mdladvObj,hDI);


    if hDI.isToolEmpty


        isToolSupported=true;
    else

        isToolSupported=hDI.hAvailableToolList.isToolVersionSupported(hDI.get('Tool'));
    end



    if~isToolSupported
        AllowToolVersionOption.Value=hDI.getAllowUnsupportedToolVersion();
    else
        AllowToolVersionOption.Value=false;
    end



    AllowToolVersionOption.Enable=~isToolSupported;


