function paramTargetDevice(taskobj)



    mdladvObj=taskobj.MAObj;


    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;


    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    workflowOption=inputParams{1};
    boardOption=inputParams{2};
    toolOption=inputParams{3};
    familyOption=inputParams{4};
    deviceOption=inputParams{5};
    packageOption=inputParams{6};
    speedOption=inputParams{7};
    folderOption=inputParams{8};
    allowUnsupportedToolVersionOption=inputParams{13};

    try
        updateParameterName='';
        if~strcmp(workflowOption.Value,hDI.get('Workflow'))
            updateParameterName='workflow';
            hDI.set('Workflow',workflowOption.Value);


            utilCleanTargetInterfaceTable(mdladvObj,hDI);

            utilAdjustWorkflowParameter(mdladvObj,hDI);










            if hDI.isShowTargetFrequencyTask
                utilAdjustTargetFrequency(mdladvObj,hDI);
            end
        elseif~strcmp(boardOption.Value,hDI.get('Board'))
            updateParameterName='board';



            if hDI.isUSRPWorkflow&&~isempty(strfind(boardOption.Value,'N210'))
                hf=warndlg(DAStudio.message('hdlcommon:workflow:DepricateUSRPN2xxBoards'),'Warning','modal');
                uiwait(hf);
            end

            if strcmp(boardOption.Value,hDI.GetMoreStr)||strcmp(boardOption.Value,hDI.GetMoreBoardStr)

                boardOption.Value=hDI.get('Board');
                hMAExplorer=mdladvObj.MAExplorer;
                currentDialog=hMAExplorer.getDialog;
                currentDialog.setWidgetValue('InputParameters_2',getIndexNumber(hDI.EmptyBoardStr,hDI.set('Board')));

                if hDI.isFILWorkflow
                    matlab.addons.supportpackage.internal.explorer.showSupportPackages(...
                    {'HDLCVXILINX','HDLVALTERA'},'tripwire');
                elseif hDI.isIPWorkflow
                    matlab.addons.supportpackage.internal.explorer.showSupportPackages(...
                    {'HCZYNQ7000','ECZYNQ7000',...
                    'HDL_ALTERA_SOC','EC_ALTERA_SOC',...
                    'HDLCALTERA','HDLCXILINX',...
                    'VP_VISION_ZYNQ'},'tripwire');
                elseif hDI.isTurnkeyWorkflow
                    matlab.addons.supportpackage.internal.explorer.showSupportPackages(...
                    {'HDLCALTERA','HDLCXILINX'},'tripwire');
                elseif hDI.isSLRTWorkflow


                    hf=warndlg(DAStudio.message('hdlcoder:workflow:GetSpeedgoatBoard'),'Warning','modal');
                    uiwait(hf);
                end

            elseif strcmp(boardOption.Value,hDI.AddNewBoardStr)

                boardOption.Value=hDI.get('Board');
                hMAExplorer=mdladvObj.MAExplorer;
                currentDialog=hMAExplorer.getDialog;
                currentDialog.setWidgetValue('InputParameters_2',getIndexNumber(hDI.EmptyBoardStr,hDI.set('Board')));

                hWizardDlg=boardmanagergui.NewBoardWizard(taskobj);
                DAStudio.Dialog(hWizardDlg);
            else

                hDI.set('Board',boardOption.Value);

                if(hDI.isSLRTWorkflow)
                    hDI.SkipPlaceAndRoute=false;
                    hDI.SkipPreRouteTimingAnalysis=true;
                end

                utilCleanTargetInterfaceTable(mdladvObj,hDI);


                if hDI.isShowTargetFrequencyTask
                    utilAdjustTargetFrequency(mdladvObj,hDI);
                end


                utilAdjustWorkflowParameter(mdladvObj,hDI);


                checkxPCTargetLicense(hDI);


                hMAExplorer=mdladvObj.MAExplorer;
                currentDialog=hMAExplorer.getDialog;
                currentDialog.setWidgetValue('InputParameters_4',getIndexNumber(hDI.get('Family'),hDI.set('Family')));
            end

            hDI.set('Board',boardOption.Value);

        elseif~strcmp(toolOption.Value,hDI.get('Tool'))
            updateParameterName='tool';
            hDI.set('Tool',toolOption.Value);


            if(~hDI.isIPCoreGen&&strcmp(hDI.get('Tool'),'Xilinx ISE'))
                hDI.setObjectiveFromName('None');
            end


            if(hDI.isSLRTWorkflow)
                hDI.SkipPlaceAndRoute=false;
                hDI.SkipPreRouteTimingAnalysis=true;
            end

            utilCleanTargetInterfaceTable(mdladvObj,hDI);


            utilAdjustWorkflowParameter(mdladvObj,hDI);


            isToolVersionSupported=hDI.hAvailableToolList.isToolVersionSupported(hDI.get('Tool'));
            if~isToolVersionSupported
                hDI.setAllowUnsupportedToolVersion(allowUnsupportedToolVersionOption.Value);
            end

        elseif~strcmp(familyOption.Value,hDI.get('Family'))
            hDI.set('Family',familyOption.Value);
        elseif~strcmp(deviceOption.Value,hDI.get('Device'))
            hDI.set('Device',deviceOption.Value);
        elseif~strcmp(packageOption.Value,hDI.get('Package'))
            hDI.set('Package',packageOption.Value);
        elseif~strcmp(speedOption.Value,hDI.get('Speed'))
            hDI.set('Speed',speedOption.Value);
        elseif~strcmp(folderOption.Value,hDI.getProjectFolder)
            updateParameterName='folder';
            hDI.setProjectFolder(folderOption.Value);

            utilAdjustWorkflowParameter(mdladvObj,hDI);
        elseif allowUnsupportedToolVersionOption.Value~=hDI.getAllowUnsupportedToolVersion
            toolName=hDI.get('Tool');
            if~hDI.hAvailableToolList.isToolVersionSupported(toolName)
                hDI.setAllowUnsupportedToolVersion(allowUnsupportedToolVersionOption.Value);
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
            if strcmpi(updateParameterName,'workflow')
                currentDialog.setWidgetValue('InputParameters_1',getIndexNumber(hDI.get('Target'),hDI.set('Target')));
            elseif strcmpi(updateParameterName,'board')
                currentDialog.setWidgetValue('InputParameters_2',getIndexNumber(hDI.get('Board'),hDI.set('Board')));
            elseif strcmpi(updateParameterName,'tool')
                currentDialog.setWidgetValue('InputParameters_3',getIndexNumber(hDI.get('Tool'),hDI.set('Tool')));
            elseif strcmpi(updateParameterName,'folder')
                currentDialog.setWidgetValue('InputParameters_8',hDI.getProjectFolder);
            end
        end
    end


    utilAdjustTargetDevice(mdladvObj,hDI);


    utilAdjustCreateProject(mdladvObj,hDI);

end


function checkxPCTargetLicense(hDI)


    if hDI.isXPCWorkflow&&hDI.isxPCTargetBoard&&~hdlturnkey.isxpcinstalled
        warnMsg=['Simulink Real-Time is not licensed or installed. Please make ',...
        'sure Simulink Real-Time is licensed and installed in order to ',...
        'run Task 5.2 Generate Simulink Real-Time interface.'];

        hf=warndlg(warnMsg,'Warning','modal');

        set(hf,'tag','Simulink Real-Time License warning dialog');

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


