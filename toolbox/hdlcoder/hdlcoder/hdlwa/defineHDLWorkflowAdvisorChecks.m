function recordCellArray=defineHDLWorkflowAdvisorChecks




    recordCellArray={};



    try

        if~hdlcoderui.isslhdlcinstalled
            hDI=[];
        else
            mdlName=hdlwa.hdlwaDriver.modelName;
            if~isempty(mdlName)
                hc=hdlmodeldriver(mdlName);
                hDI=hc.DownstreamIntegrationDriver;
            else
                hDI=[];
            end
        end
    catch %#ok<CTCH>
        hDI=[];
    end


    if~isempty(hDI)
        workflowList=hDI.set('Workflow');
        boardList=hDI.set('Board');
        toolList=hDI.set('Tool');
        familyList=hDI.set('Family');
        deviceList=hDI.set('Device');
        packageList=hDI.set('Package');
        speedList=hDI.set('Speed');
        execModeList=hDI.set('ExecutionMode');
        workflowValue=hDI.get('Workflow');
        toolValue=hDI.get('Tool');
        boardValue=hDI.get('Board');
        familyValue=hDI.get('Family');
        deviceValue=hDI.get('Device');
        packageValue=hDI.get('Package');
        speedValue=hDI.get('Speed');
        projectDir=hDI.getProjectPath;
        customHDLFile=hDI.getCustomSourceFile;
        customTclFile=hDI.getCustomTclFile;
        folderValue=hDI.getProjectFolder;
        execModeValue=hDI.get('ExecutionMode');
        objectiveList=getObjectiveList(hdlcoder.Objective.None);

        objectiveValue='None';
        customBuildTcl='';
        designCheckpointFileEnb='';
        generateCode=hDI.GenerateRTLCode;
        generateTestbench=hDI.GenerateTestbench;
        generateValidationModel=hDI.GenerateValidationModel;
        toolVersion=hDI.getToolVersion;
        testPointValue=hDI.isTestPointEnabledOnModel;
        allowUnsupportedToolVersion=hDI.getAllowUnsupportedToolVersion();
        isToolVersionSupported=hDI.hAvailableToolList.isToolVersionSupported(hDI.get('Tool'));
    else
        workflowList={''};
        boardList={''};
        toolList={''};
        familyList={''};
        deviceList={''};
        packageList={''};
        execModeList={''};
        speedList={''};
        objectiveList={''};
        workflowValue='';
        toolValue='';
        boardValue='';
        familyValue='';
        deviceValue='';
        packageValue='';
        speedValue='';
        projectDir='';
        customHDLFile='';
        customTclFile='';
        folderValue='';
        execModeValue='';
        objectiveValue='';
        customBuildTcl='';
        designCheckpointFileEnb='';
        generateCode=false;
        generateTestbench=false;
        generateValidationModel=false;
        toolVersion='';
        testPointValue=false;
        allowUnsupportedToolVersion=false;
        isToolVersionSupported=true;
    end

    if~isempty(hDI)&&~isempty(hDI.hIP)

        ipName=hDI.hIP.getIPCoreName;
        ipVer=hDI.hIP.getIPCoreVersion;
        ipFolder=hDI.hIP.getIPCoreFolder;
        ipRepository=hDI.hIP.getIPRepository;
        ipCustomFile=hDI.hIP.getIPCoreCustomFile;
        ipReport=hDI.hIP.getIPCoreReportStatus;
        ipBufferSize=hDI.hIP.getIPDataCaptureBufferSize;
        ipSequenceDepth=hDI.hIP.getIPDataCaptureSequenceDepth;
        IncludeDataCaptureControlLogicEnable=hDI.hIP.getIncludeDataCaptureControlLogicEnable;
        IDWidth=hDI.hIP.getIDWidth;
        ipcacheValue=hDI.hIP.getUseIPCache;
        axi4Readback=hDI.hIP.getAXI4ReadbackEnable;
        axi4SlaveEnab=hDI.hIP.getAXI4SlaveEnable;
        exposeDUTClockEnab=hDI.hIP.getDUTClockEnable;
        exposeDUTCEOut=hDI.hIP.getDUTCEOut;
        axi4SlavePipelineRegisterPerPort=hDI.hIP.getInsertAXI4PipelineRegisterEnable;


        emtoolValue=hDI.hIP.getEmbeddedTool;
        emprojDir=hDI.hIP.getEmbeddedToolProjFolder;


        osList=hDI.hIP.getOperatingSystemAll;
        osValue=hDI.hIP.getOperatingSystem;


        hostInterfaceList=hDI.hIP.getHostTargetInterfaceOptions;
        hostInterfaceValue=hDI.hIP.getHostTargetInterface;


        emexbValue=hDI.hIP.getEmbeddedExternalBuild;
        designCheckpointEnb=hDI.getEnableDesignCheckpoint;
        maxNumOfCores=hDI.getMaxNumOfCores;


        programList=hdlcoder.ProgrammingMethod.convertToString(hDI.hIP.getProgrammingMethodAll);
        if~iscell(programList)
            programList={programList};
        end
        programValue=hdlcoder.ProgrammingMethod.convertToString(hDI.hIP.getProgrammingMethod);
        ipAddr=hDI.hIP.getIPAddress;
        sshUsername=hDI.hIP.getSSHUsername;
        sshPassword=hDI.hIP.getSSHPassword;
    else

        ipName='';
        ipVer='';
        ipFolder='';
        ipRepository='';
        ipCustomFile='';
        ipReport=false;
        ipBufferSize='128';
        ipSequenceDepth='1';
        IncludeDataCaptureControlLogicEnable=false;
        IDWidth='12';
        ipcacheValue=false;
        axi4Readback=false;
        axi4SlaveEnab=true;
        exposeDUTClockEnab=false;
        exposeDUTCEOut=false;
        axi4SlavePipelineRegisterPerPort='auto';


        emtoolValue='';
        emprojDir='';


        osList={''};
        osValue='';


        hostInterfaceList={''};
        hostInterfaceValue='';


        emexbValue=false;
        designCheckpointEnb=false;
        maxNumOfCores='synthesis tool default';


        programList={''};
        programValue='';
        ipAddr='';
        sshUsername='';
        sshPassword='';
    end


    tableSetting=hdlturnkey.data.interfaceTableInitFormat;



    rec=ModelAdvisor.Check('com.mathworks.HDL.SetTargetDevice');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleSetTargetDevice');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@setTargetDevice;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[6,8];
    rec.setInputParametersCallbackFcn(@paramTargetDevice);


    targetInputParam{1}=ModelAdvisor.InputParameter;
    targetInputParam{1}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputTargetWorkflow');
    targetInputParam{1}.Type='Enum';
    targetInputParam{1}.Entries=workflowList;
    targetInputParam{1}.Value=workflowValue;
    targetInputParam{1}.Description='Choose target workflow';
    targetInputParam{1}.setRowSpan([1,1]);
    targetInputParam{1}.setColSpan([1,8]);


    targetInputParam{end+1}=ModelAdvisor.InputParameter;
    targetInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputTargetPlatform');
    targetInputParam{end}.Type='Enum';
    targetInputParam{end}.Entries=boardList;
    targetInputParam{end}.Value=boardValue;
    targetInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescTargetPlatform');
    targetInputParam{end}.setRowSpan([2,2]);
    targetInputParam{end}.setColSpan([1,6]);


    targetInputParam{end+1}=ModelAdvisor.InputParameter;
    targetInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputSynthesisTool');
    targetInputParam{end}.Type='Enum';
    targetInputParam{end}.Entries=toolList;
    targetInputParam{end}.Value=toolValue;
    targetInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescSynthesisTool');
    targetInputParam{end}.setRowSpan([3,3]);
    targetInputParam{end}.setColSpan([1,3]);


    targetInputParam{end+1}=ModelAdvisor.InputParameter;
    targetInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputFamily');
    targetInputParam{end}.Type='Enum';
    targetInputParam{end}.Entries=familyList;
    targetInputParam{end}.Value=familyValue;
    targetInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescFamily');
    targetInputParam{end}.setRowSpan([4,4]);
    targetInputParam{end}.setColSpan([1,4]);


    targetInputParam{end+1}=ModelAdvisor.InputParameter;
    targetInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputDevice');
    targetInputParam{end}.Type='Enum';
    targetInputParam{end}.Entries=deviceList;
    targetInputParam{end}.Value=deviceValue;
    targetInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescDevice');
    targetInputParam{end}.setRowSpan([4,4]);
    targetInputParam{end}.setColSpan([5,8]);


    targetInputParam{end+1}=ModelAdvisor.InputParameter;
    targetInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputPackage');
    targetInputParam{end}.Type='Enum';
    targetInputParam{end}.Entries=packageList;
    targetInputParam{end}.Value=packageValue;
    targetInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescPackage');
    targetInputParam{end}.setRowSpan([5,5]);
    targetInputParam{end}.setColSpan([1,4]);


    targetInputParam{end+1}=ModelAdvisor.InputParameter;
    targetInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputSpeed');
    targetInputParam{end}.Type='Enum';
    targetInputParam{end}.Entries=speedList;
    targetInputParam{end}.Value=speedValue;
    targetInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescSpeed');
    targetInputParam{end}.setRowSpan([5,5]);
    targetInputParam{end}.setColSpan([5,8]);


    targetInputParam{end+1}=ModelAdvisor.InputParameter;
    targetInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputProjectFolder');
    targetInputParam{end}.Type='String';
    targetInputParam{end}.Value=folderValue;
    targetInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescProjectFolder');
    targetInputParam{end}.setRowSpan([6,6]);
    targetInputParam{end}.setColSpan([1,7]);


    targetInputParam{end+1}=ModelAdvisor.InputParameter;
    targetInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputBrowse');
    targetInputParam{end}.Type='PushButton';
    targetInputParam{end}.Entries=@actionBrowseProjDir;
    targetInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescBrowse');
    targetInputParam{end}.setRowSpan([6,6]);
    targetInputParam{end}.setColSpan([8,8]);


    targetInputParam{end+1}=ModelAdvisor.InputParameter;
    targetInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputLaunchBoardManager');
    targetInputParam{end}.Type='PushButton';
    targetInputParam{end}.Entries=@actionFPGABoardManager;
    targetInputParam{end}.Enable=false;
    targetInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescLaunchBoardManager');
    targetInputParam{end}.setRowSpan([2,2]);
    targetInputParam{end}.setColSpan([7,8]);


    targetInputParam{end+1}=ModelAdvisor.InputParameter;
    targetInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWARefreshSynthesisTool');
    targetInputParam{end}.Type='PushButton';
    targetInputParam{end}.Entries=@actionRefreshTool;
    targetInputParam{end}.Enable=true;
    targetInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescRefreshSynthesisTool');
    targetInputParam{end}.setRowSpan([3,3]);
    targetInputParam{end}.setColSpan([8,8]);


    targetInputParam{end+1}=ModelAdvisor.InputParameter;
    targetInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputSynthesisToolVersion');
    targetInputParam{end}.Type='String';
    targetInputParam{end}.Value=toolVersion;
    targetInputParam{end}.Enable=false;
    targetInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescSynthesisToolVersion');
    targetInputParam{end}.setRowSpan([3,3]);
    targetInputParam{end}.setColSpan([4,5]);


    targetInputParam{end+1}=ModelAdvisor.InputParameter;
    targetInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAUnsupportedToolVersion');
    targetInputParam{end}.Type='Bool';
    targetInputParam{end}.Value=allowUnsupportedToolVersion;
    targetInputParam{end}.Enable=~isToolVersionSupported;
    targetInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescUnsupportedToolVersionAllow');
    targetInputParam{end}.setRowSpan([3,3]);
    targetInputParam{end}.setColSpan([6,7]);
    rec.setInputParameters(targetInputParam);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.SetTargetReferenceDesign');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleSetTargetReferenceDesign');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@setTargetReferenceDesign;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[8,8];
    rec.setInputParametersCallbackFcn(@paramTargetReferenceDesign);

    rdInputParam={};


    rdInputParam{1}=ModelAdvisor.InputParameter;
    rdInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAReferenceDesign');
    rdInputParam{end}.Type='Enum';
    rdInputParam{end}.Entries={''};
    rdInputParam{end}.Value='';
    rdInputParam{end}.Enable=false;
    rdInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescReferenceDesign');
    rdInputParam{end}.setRowSpan([1,1]);
    rdInputParam{end}.setColSpan([1,8]);


    rdInputParam{end+1}=ModelAdvisor.InputParameter;
    rdInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWARDToolVersion');
    rdInputParam{end}.Type='Enum';
    rdInputParam{end}.Entries={''};
    rdInputParam{end}.Value='';
    rdInputParam{end}.Enable=false;
    rdInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescRDToolVersion');
    rdInputParam{end}.setRowSpan([2,2]);
    rdInputParam{end}.setColSpan([1,4]);


    rdInputParam{end+1}=ModelAdvisor.InputParameter;
    rdInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWARDToolVersionIgnore');
    rdInputParam{end}.Type='Bool';
    rdInputParam{end}.Value=false;
    rdInputParam{end}.Enable=false;
    rdInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescRDToolVersionIgnore');
    rdInputParam{end}.setRowSpan([2,2]);
    rdInputParam{end}.setColSpan([5,8]);


    rdInputParam{end+1}=ModelAdvisor.InputParameter;
    rdInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputRDParameterTable');
    rdInputParam{end}.Type='Table';
    rdInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescRDParameterTable');
    rdInputParam{end}.Value=true;
    rdInputParam{end}.setRowSpan([3,3]);
    rdInputParam{end}.setColSpan([1,6]);
    rdInputParam{end}.TableSetting=hdlturnkey.data.paramTableInitFormat;
    rdInputParam{end}.TableSetting.ValueChangedCallback=@callbackRDParameterTable;

    rec.setInputParameters(rdInputParam);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.SetTargetInterface');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleSetTargetInterface');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@setTargetInterface;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[1,8];


    ioInputParam{1}=ModelAdvisor.InputParameter;
    ioInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputTargetPlatformInterfaceTable');
    ioInputParam{end}.Type='Table';
    ioInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescTargetPlatformInterfaceTable');
    ioInputParam{end}.Value=true;
    ioInputParam{end}.setRowSpan([1,1]);
    ioInputParam{end}.setColSpan([1,8]);
    ioInputParam{end}.TableSetting=tableSetting;
    ioInputParam{end}.TableSetting.ValueChangedCallback=@callbackInterfaceTable;
    ioInputParam{end}.TableSetting.ItemClickedCallback=@callbackInterfaceTable;

    rec.setInputParameters(ioInputParam);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.SetTargetInterfaceAndMode');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleSetTargetInterface');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@setTargetInterface;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[8,8];
    rec.setInputParametersCallbackFcn(@paramTargetInterface);




    ioInputParam{1}=ModelAdvisor.InputParameter;
    ioInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputFPGAExecutionMode');
    ioInputParam{end}.Type='Enum';
    ioInputParam{end}.Entries=execModeList;
    ioInputParam{end}.Value=execModeValue;
    ioInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescFPGAExecutionMode');
    ioInputParam{end}.setRowSpan([1,1]);
    ioInputParam{end}.setColSpan([1,6]);


    ioInputParam{end+1}=ModelAdvisor.InputParameter;
    ioInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputTargetPlatformInterfaceTable');
    ioInputParam{end}.Type='Table';
    ioInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescTargetPlatformInterfaceTable');
    ioInputParam{end}.Value=true;
    ioInputParam{end}.setRowSpan([4,8]);
    ioInputParam{end}.setColSpan([1,8]);
    ioInputParam{end}.TableSetting=tableSetting;
    ioInputParam{end}.TableSetting.ValueChangedCallback=@callbackInterfaceTable;
    ioInputParam{end}.TableSetting.ItemClickedCallback=@callbackInterfaceTable;


    ioInputParam{end+1}=ModelAdvisor.InputParameter;
    ioInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:hdlglblsettingsEnableTestpoints');
    ioInputParam{end}.Type='Bool';
    ioInputParam{end}.Value=testPointValue;
    ioInputParam{end}.Enable=true;
    ioInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:hdlglblsettingsEnableTestpoints');
    ioInputParam{end}.setRowSpan([2,2]);
    ioInputParam{end}.setColSpan([1,3]);


    ioInputParam{end+1}=ModelAdvisor.InputParameter;
    ioInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAGenerateAXI4Slave');
    ioInputParam{end}.Type='Bool';
    ioInputParam{end}.Value=axi4SlaveEnab;
    ioInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAGenerateAXI4Slave');
    ioInputParam{end}.setRowSpan([3,3]);
    ioInputParam{end}.setColSpan([1,3]);




















    rec.setInputParameters(ioInputParam);
    recordCellArray{end+1}=rec;



    rec=ModelAdvisor.Check('com.mathworks.HDL.SetGenericTargetFrequency');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWASetTargetFrequency');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runTargetFrequency;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[1,8];
    rec.setInputParametersCallbackFcn(@paramTargetFrequency);

    freqGenericInputParam{1}=ModelAdvisor.InputParameter;
    freqGenericInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputTargetFrequency');
    freqGenericInputParam{end}.Type='String';
    freqGenericInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescGenericTargetFrequency');
    freqGenericInputParam{end}.Value='0';
    freqGenericInputParam{end}.setRowSpan([1,1]);
    freqGenericInputParam{end}.setColSpan([1,4]);

    rec.setInputParameters(freqGenericInputParam);
    recordCellArray{end+1}=rec;



    rec=ModelAdvisor.Check('com.mathworks.HDL.SetTargetFrequency');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWASetTargetFrequency');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runTargetFrequency;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[1,8];
    rec.setInputParametersCallbackFcn(@paramTargetFrequency);



    freqInputParam{1}=ModelAdvisor.InputParameter;
    freqInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputTargetFrequency');
    freqInputParam{end}.Type='String';
    freqInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescSystemInputClockFrequency');
    freqInputParam{end}.Value='0';
    freqInputParam{end}.setRowSpan([1,1]);
    freqInputParam{end}.setColSpan([1,4]);


    freqInputParam{end+1}=ModelAdvisor.InputParameter;
    freqInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputTargetFrequencyDefault');
    freqInputParam{end}.Type='String';
    freqInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescTargetFrequencyDefault');
    freqInputParam{end}.Value='0';
    freqInputParam{end}.Enable=false;
    freqInputParam{end}.setRowSpan([2,2]);
    freqInputParam{end}.setColSpan([1,3]);

    freqInputParam{end+1}=ModelAdvisor.InputParameter;
    freqInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputTargetFrequencyRestoreDefault');
    freqInputParam{end}.Type='PushButton';
    freqInputParam{end}.Entries=@actionRestoreDefaultTargetFrequency;
    freqInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescTargetFrequencyRestoreDefault');
    freqInputParam{end}.setRowSpan([2,2]);
    freqInputParam{end}.setColSpan([4,4]);

    freqInputParam{end+1}=ModelAdvisor.InputParameter;
    freqInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputTargetFrequencyRange');
    freqInputParam{end}.Type='String';
    freqInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescTargetFrequencyRange');
    freqInputParam{end}.Value='none';
    freqInputParam{end}.Enable=false;
    freqInputParam{end}.setRowSpan([3,3]);
    freqInputParam{end}.setColSpan([1,4]);


    rec.setInputParameters(freqInputParam);
    recordCellArray{end+1}=rec;





    rec=ModelAdvisor.Check('com.mathworks.HDL.CheckModelSettings');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleCheckModelLevelSettings');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@checkModelSettings;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[1,4];


    modifyAllAction=ModelAdvisor.Action;
    modifyAllAction.setCallbackFcn(@actionModelSettings);
    modifyAllAction.Name=DAStudio.message('HDLShared:hdldialog:MSGModifyAll');
    modifyAllAction.Description=DAStudio.message('HDLShared:hdldialog:HDLWAActionDescConfigureModel');
    rec.setAction(modifyAllAction);


    codeAdvisorInputParam{1}=ModelAdvisor.InputParameter;
    codeAdvisorInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWALaunchCodeAdvisor');
    codeAdvisorInputParam{end}.Type='PushButton';
    codeAdvisorInputParam{end}.Entries=@actionLaunchCodeAdvisor;
    codeAdvisorInputParam{end}.Enable=true;
    codeAdvisorInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescLaunchCodeAdvisor');
    codeAdvisorInputParam{end}.setRowSpan([1,1]);
    codeAdvisorInputParam{end}.setColSpan([1,1]);

    rec.setInputParameters(codeAdvisorInputParam);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.CheckFIL');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleCheckFILCompatibility');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@checkFILCompatibility;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.Enable=true;
    rec.LicenseName={'Simulink_HDL_Coder'};

    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.CheckUSRP');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleCheckUsrpCompatibility');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@checkFILCompatibility;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.Enable=true;
    rec.LicenseName={'Simulink_HDL_Coder'};

    recordCellArray{end+1}=rec;




    rec=ModelAdvisor.Check('com.mathworks.HDL.SetHDLOptions');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleSetHDLOptions');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@setHDLOptions;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[1,4];

    codeSettingsInputParam{1}=ModelAdvisor.InputParameter;
    codeSettingsInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWALaunchConfigSet');
    codeSettingsInputParam{end}.Type='PushButton';
    codeSettingsInputParam{end}.Entries=@actionLaunchHDLSettings;
    codeSettingsInputParam{end}.Enable=true;
    codeSettingsInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescLaunchConfigSet');
    codeSettingsInputParam{end}.setRowSpan([1,1]);
    codeSettingsInputParam{end}.setColSpan([1,1]);

    rec.setInputParameters(codeSettingsInputParam);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.GenerateHDLCodeAndReport');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleGenerateRTLCode');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runGenerateRTLCodeAndTestbench;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.setInputParametersCallbackFcn(@paramGenerateHDLCode);
    rec.LicenseName={'Simulink_HDL_Coder'};

    codegenInputParam{1}=ModelAdvisor.InputParameter;
    codegenInputParam{1}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputGenerateRTLCode');
    codegenInputParam{1}.Type='Bool';
    codegenInputParam{1}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescGenerateRTLCode');
    codegenInputParam{1}.Value=generateCode;
    codegenInputParam{1}.RowSpan=[1,1];
    codegenInputParam{1}.ColSpan=[1,8];

    codegenInputParam{end+1}=ModelAdvisor.InputParameter;
    codegenInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputGenerateTestbench');
    codegenInputParam{end}.Type='Bool';
    codegenInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescGenerateTestbench');
    codegenInputParam{end}.Value=generateTestbench;
    codegenInputParam{end}.RowSpan=[2,2];
    codegenInputParam{end}.ColSpan=[1,8];

    codegenInputParam{end+1}=ModelAdvisor.InputParameter;
    codegenInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputGenerateCovalidationModel');
    codegenInputParam{end}.Type='Bool';
    codegenInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescGenerateCovalidationModel');
    codegenInputParam{end}.Value=generateValidationModel;
    codegenInputParam{end}.RowSpan=[3,3];
    codegenInputParam{end}.ColSpan=[1,8];

    rec.setInputParameters(codegenInputParam);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.VerifyCosim');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleVerifyCosim');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@verifyCosim;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[1,8];
    rec.setInputParametersCallbackFcn(@paramVerifyCosim)


    VerifyCosimInputParam{1}=ModelAdvisor.InputParameter;
    VerifyCosimInputParam{1}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputSkipThisTask');
    VerifyCosimInputParam{1}.Type='Bool';
    VerifyCosimInputParam{1}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescSkipThisTask');
    VerifyCosimInputParam{1}.Value=false;
    VerifyCosimInputParam{1}.RowSpan=[1,1];
    VerifyCosimInputParam{1}.ColSpan=[1,8];

    rec.setInputParameters(VerifyCosimInputParam);
    recordCellArray{end+1}=rec;



    rec=ModelAdvisor.Check('com.mathworks.HDL.GenerateIPCore');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleGenerateIPCore');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@generateIPCore;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[6,8];
    rec.setInputParametersCallbackFcn(@paramGenerateIPCore)

    ipInputParam={};
    paramIdx=0;


    paramIdx=paramIdx+1;
    ipInputParam{end+1}=ModelAdvisor.InputParameter;
    ipInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAIPCoreName');
    ipInputParam{end}.Type='String';
    ipInputParam{end}.Value=ipName;
    ipInputParam{end}.Enable=true;
    ipInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescIPCoreName');
    ipInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ipInputParam{end}.setColSpan([1,8]);


    paramIdx=paramIdx+1;
    ipInputParam{end+1}=ModelAdvisor.InputParameter;
    ipInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAIPCoreVersion');
    ipInputParam{end}.Type='String';
    ipInputParam{end}.Value=ipVer;
    ipInputParam{end}.Enable=true;
    ipInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescIPCoreVersion');
    ipInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ipInputParam{end}.setColSpan([1,8]);


    paramIdx=paramIdx+1;
    ipInputParam{end+1}=ModelAdvisor.InputParameter;
    ipInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAIPCoreFolder');
    ipInputParam{end}.Type='String';
    ipInputParam{end}.Value=ipFolder;
    ipInputParam{end}.Enable=false;
    ipInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescIPCoreFolder');
    ipInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ipInputParam{end}.setColSpan([1,8]);


    paramIdx=paramIdx+1;
    ipInputParam{end+1}=ModelAdvisor.InputParameter;
    ipInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAIPRepository');
    ipInputParam{end}.Type='String';
    ipInputParam{end}.Value=ipRepository;
    ipInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescIPRepository');
    ipInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ipInputParam{end}.setColSpan([1,7]);


    ipInputParam{end+1}=ModelAdvisor.InputParameter;
    ipInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputBrowse');
    ipInputParam{end}.Type='PushButton';
    ipInputParam{end}.Entries=@actionBrowseIPRepository;
    ipInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescBrowseIP');
    ipInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ipInputParam{end}.setColSpan([8,8]);


    paramIdx=paramIdx+1;
    ipInputParam{end+1}=ModelAdvisor.InputParameter;
    ipInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputAdditionalSourceFiles');
    ipInputParam{end}.Type='String';
    ipInputParam{end}.Value=ipCustomFile;
    ipInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescAdditionalSourceFilesIP');
    ipInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ipInputParam{end}.setColSpan([1,7]);


    ipInputParam{end+1}=ModelAdvisor.InputParameter;
    ipInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputAdd');
    ipInputParam{end}.Type='PushButton';
    ipInputParam{end}.Entries=@actionBrowseCustomFile;
    ipInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescAdd');
    ipInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ipInputParam{end}.setColSpan([8,8]);


    paramIdx=paramIdx+1;
    ipInputParam{end+1}=ModelAdvisor.InputParameter;
    ipInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAIPDataCaptureBufferSize');
    ipInputParam{end}.Type='Enum';
    ipInputParam{end}.Entries=arrayfun(@(x)num2str(x),2.^[7:20],'UniformOutput',false);
    ipInputParam{end}.Value=num2str(ipBufferSize);
    ipInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAIPDataCaptureBufferSizeStr');
    ipInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ipInputParam{end}.setColSpan([1,8]);


    paramIdx=paramIdx+1;
    ipInputParam{end+1}=ModelAdvisor.InputParameter;
    ipInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAIPDataCaptureSequenceDepth');
    ipInputParam{end}.Type='Enum';
    ipInputParam{end}.Entries=arrayfun(@(x)num2str(x),1:10,'UniformOutput',false);
    ipInputParam{end}.Value=num2str(ipSequenceDepth);
    ipInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAIPDataCaptureSequenceDepthStr');
    ipInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ipInputParam{end}.setColSpan([1,8]);


    paramIdx=paramIdx+1;
    ipInputParam{end+1}=ModelAdvisor.InputParameter;
    ipInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAIncludeDataCaptureControlLogicEnable');
    ipInputParam{end}.Type='Bool';
    ipInputParam{end}.Value=IncludeDataCaptureControlLogicEnable;
    ipInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAIncludeDataCaptureControlLogicEnableStr');
    ipInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ipInputParam{end}.setColSpan([1,3]);


    paramIdx=paramIdx+1;
    ipInputParam{end+1}=ModelAdvisor.InputParameter;
    ipInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputAXISlaveIDWidth');
    ipInputParam{end}.Type='String';
    ipInputParam{end}.Value=IDWidth;
    ipInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescAXISlaveIDWidth');
    ipInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ipInputParam{end}.setColSpan([1,8]);


    paramIdx=paramIdx+1;
    ipInputParam{end+1}=ModelAdvisor.InputParameter;
    ipInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAAXI4SlavePortToPipelineRegisterRatio');
    ipInputParam{end}.Type='Enum';
    ipInputParam{end}.Entries={'auto','off','10','20','35','50'};
    ipInputParam{end}.Value=axi4SlavePipelineRegisterPerPort;
    ipInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAAXI4SlavePortToPipelineRegisterRatioStr');
    ipInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ipInputParam{end}.setColSpan([1,8]);


    paramIdx=paramIdx+1;
    ipInputParam{end+1}=ModelAdvisor.InputParameter;
    ipInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAIPCoreReport');
    ipInputParam{end}.Type='Bool';
    ipInputParam{end}.Value=ipReport;
    ipInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescIPCoreReport');
    ipInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ipInputParam{end}.setColSpan([1,8]);


    paramIdx=paramIdx+1;
    ipInputParam{end+1}=ModelAdvisor.InputParameter;
    ipInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAEnableAXI4SlaveReadback');
    ipInputParam{end}.Type='Bool';
    ipInputParam{end}.Value=axi4Readback;
    ipInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAEnableAXI4SlaveReadbackCodeGen');
    ipInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ipInputParam{end}.setColSpan([1,8]);


    paramIdx=paramIdx+1;
    ipInputParam{end+1}=ModelAdvisor.InputParameter;
    ipInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAEnableDUTClockEnable');
    ipInputParam{end}.Type='Bool';
    ipInputParam{end}.Value=exposeDUTClockEnab;
    ipInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAEnableDUTClockEnable');
    ipInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ipInputParam{end}.setColSpan([1,3]);


    ipInputParam{end+1}=ModelAdvisor.InputParameter;
    ipInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAEnableCEOut');
    ipInputParam{end}.Type='Bool';
    ipInputParam{end}.Value=exposeDUTCEOut;
    ipInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAEnableCEOut');
    ipInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ipInputParam{end}.setColSpan([4,6]);










    rec.setInputParameters(ipInputParam);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.GenerateRTLCode');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleGenerateRTLCodeAndTop');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runGenerateRTLCode;
    rec.CallbackContext='DIY';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    recordCellArray{end+1}=rec;




    rec=ModelAdvisor.Check('com.mathworks.HDL.CreateProject');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleCreateSynthesisToolProject');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runCreateProject;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[10,8];
    rec.setInputParametersCallbackFcn(@paramCreateProject);

    iseInputParam={};
    paramIdx=0;


    paramIdx=paramIdx+1;
    iseInputParam{end+1}=ModelAdvisor.InputParameter;
    iseInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputProjectFolder');
    iseInputParam{end}.Type='String';
    iseInputParam{end}.Value=projectDir;
    iseInputParam{end}.Enable=false;
    iseInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescProjectDirectory');
    iseInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    iseInputParam{end}.setColSpan([1,7]);











    paramIdx=paramIdx+1;
    iseInputParam{end+1}=ModelAdvisor.InputParameter;
    iseInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAObjective');
    iseInputParam{end}.Type='Enum';
    iseInputParam{end}.Entries=objectiveList;
    iseInputParam{end}.Value=objectiveValue;
    iseInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescObjective');
    iseInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    iseInputParam{end}.setColSpan([1,3]);


    paramIdx=paramIdx+1;
    iseInputParam{end+1}=ModelAdvisor.InputParameter;
    iseInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputAdditionalSourceFiles');
    iseInputParam{end}.Type='String';
    iseInputParam{end}.Value=customHDLFile;
    iseInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescAdditionalSourceFiles');
    iseInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    iseInputParam{end}.setColSpan([1,7]);

    iseInputParam{end+1}=ModelAdvisor.InputParameter;
    iseInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputAdd');
    iseInputParam{end}.Type='PushButton';
    iseInputParam{end}.Entries=@actionBrowseCustomFile;
    iseInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescAdd');
    iseInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    iseInputParam{end}.setColSpan([8,8]);


    paramIdx=paramIdx+1;
    iseInputParam{end+1}=ModelAdvisor.InputParameter;
    iseInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputAdditionalTclFiles');
    iseInputParam{end}.Type='String';
    iseInputParam{end}.Value=customTclFile;
    iseInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescAdditionalTclFiles');
    iseInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    iseInputParam{end}.setColSpan([1,7]);



    iseInputParam{end+1}=ModelAdvisor.InputParameter;
    iseInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputAdd2');
    iseInputParam{end}.Type='PushButton';
    iseInputParam{end}.Entries=@actionBrowseCustomTclFile;
    iseInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescAdd');
    iseInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    iseInputParam{end}.setColSpan([8,8]);

    rec.setInputParameters(iseInputParam);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.RunLogicSynthesis');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleRunLogicSynthesis');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runLogicSynthesis;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.RunMapping');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleRunMapping');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runMapping;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[1,8];
    rec.setInputParametersCallbackFcn(@paramRunMapping)


    mapInputParam{1}=ModelAdvisor.InputParameter;
    mapInputParam{1}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputSkipTimingAnalysis');
    mapInputParam{1}.Type='Bool';
    mapInputParam{1}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescSkipTimingAnalysis');
    mapInputParam{1}.Value=false;
    mapInputParam{1}.RowSpan=[1,1];
    mapInputParam{1}.ColSpan=[1,8];

    rec.setInputParameters(mapInputParam);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.RunPandR');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleRunPlaceAndRoute');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runPandR;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[2,8];
    rec.setInputParametersCallbackFcn(@paramDetermineBASourceOptions)


    pnrInputParam{1}=ModelAdvisor.InputParameter;
    pnrInputParam{1}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputSkipThisTask');
    pnrInputParam{1}.Type='Bool';
    pnrInputParam{1}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescSkipThisTask');
    pnrInputParam{1}.Value=true;
    pnrInputParam{1}.RowSpan=[1,1];
    pnrInputParam{1}.ColSpan=[1,8];

    pnrInputParam{2}=ModelAdvisor.InputParameter;
    pnrInputParam{2}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputIgnorePandRError');
    pnrInputParam{2}.Type='Bool';
    pnrInputParam{2}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescIgnorePandRError');
    pnrInputParam{2}.Value=false;
    pnrInputParam{2}.Enable=false;
    pnrInputParam{2}.RowSpan=[2,2];
    pnrInputParam{2}.ColSpan=[1,8];

    rec.setInputParameters(pnrInputParam);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.RunVivadoSynthesis');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleRunLogicSynthesis');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runVivadoSynthesis;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[1,8];
    rec.setInputParametersCallbackFcn(@paramRunMapping);


    mapInputParam{1}=ModelAdvisor.InputParameter;
    mapInputParam{1}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputSkipTimingAnalysis');
    mapInputParam{1}.Type='Bool';
    mapInputParam{1}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescSkipTimingAnalysis');
    mapInputParam{1}.Value=false;
    mapInputParam{1}.RowSpan=[1,1];
    mapInputParam{1}.ColSpan=[1,8];

    rec.setInputParameters(mapInputParam);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.RunImplementation');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleRunPlaceAndRoute');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runImplementation;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[2,8];
    rec.setInputParametersCallbackFcn(@paramDetermineBASourceOptions)


    pnrInputParam{1}=ModelAdvisor.InputParameter;
    pnrInputParam{1}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputSkipThisTask');
    pnrInputParam{1}.Type='Bool';
    pnrInputParam{1}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescSkipThisTask');
    pnrInputParam{1}.Value=true;
    pnrInputParam{1}.RowSpan=[1,1];
    pnrInputParam{1}.ColSpan=[1,8];

    pnrInputParam{2}=ModelAdvisor.InputParameter;
    pnrInputParam{2}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputIgnorePandRError');
    pnrInputParam{2}.Type='Bool';
    pnrInputParam{2}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescIgnorePandRError');
    pnrInputParam{2}.Value=false;
    pnrInputParam{2}.Enable=false;
    pnrInputParam{2}.RowSpan=[2,2];
    pnrInputParam{2}.ColSpan=[1,8];

    rec.setInputParameters(pnrInputParam);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.AnnotateModel');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleAnnotateSynthesisResult');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runAnnotateModel;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[4,8];
    rec.setInputParametersCallbackFcn(@paramAnnotateModel)

    baInputParam={};
    paramIdx=0;


    paramIdx=paramIdx+1;
    baInputParam{end+1}=ModelAdvisor.InputParameter;
    baInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputCriticalPathSource');
    baInputParam{end}.Type='Enum';
    baInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescCriticalPathSource');
    baInputParam{end}.Entries={'pre-route'};
    baInputParam{end}.RowSpan=[paramIdx,paramIdx];
    baInputParam{end}.ColSpan=[1,8];


    paramIdx=paramIdx+1;
    baInputParam{end+1}=ModelAdvisor.InputParameter;
    baInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputCriticalPathNumber');
    baInputParam{end}.Type='Enum';
    baInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescCriticalPathNumber');
    baInputParam{end}.Entries={'1','2','3'};
    baInputParam{end}.RowSpan=[paramIdx,paramIdx];
    baInputParam{end}.ColSpan=[1,8];


    paramIdx=paramIdx+1;
    baInputParam{end+1}=ModelAdvisor.InputParameter;
    baInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputShowAllPaths');
    baInputParam{end}.Type='Bool';
    baInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescShowAllPaths');
    baInputParam{end}.Value=false;
    baInputParam{end}.RowSpan=[paramIdx,paramIdx];
    baInputParam{end}.ColSpan=[1,4];


    baInputParam{end+1}=ModelAdvisor.InputParameter;
    baInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputShowUniquePaths');
    baInputParam{end}.Type='Bool';
    baInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescShowUniquePaths');
    baInputParam{end}.Value=false;
    baInputParam{end}.RowSpan=[paramIdx,paramIdx];
    baInputParam{end}.ColSpan=[5,8];


    paramIdx=paramIdx+1;
    baInputParam{end+1}=ModelAdvisor.InputParameter;
    baInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputShowDelayData');
    baInputParam{end}.Type='Bool';
    baInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescShowDelayData');
    baInputParam{end}.Value=true;
    baInputParam{end}.RowSpan=[paramIdx,paramIdx];
    baInputParam{end}.ColSpan=[1,4];


    baInputParam{end+1}=ModelAdvisor.InputParameter;
    baInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputShowEndsOnly');
    baInputParam{end}.Type='Bool';
    baInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescShowEndsOnly');
    baInputParam{end}.Value=false;
    baInputParam{end}.RowSpan=[paramIdx,paramIdx];
    baInputParam{end}.ColSpan=[5,8];

    rec.setInputParameters(baInputParam);


    resetAction=ModelAdvisor.Action;
    resetAction.setCallbackFcn(@actionResetAnnotation);
    resetAction.Name=DAStudio.message('HDLShared:hdldialog:HDLWAActionResetHighlighting');
    resetAction.Description=DAStudio.message('HDLShared:hdldialog:HDLWAActionDescResetHighlighting');
    rec.setAction(resetAction);

    recordCellArray{end+1}=rec;




    rec=ModelAdvisor.Check('com.mathworks.HDL.GenerateBitstream');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleGenerateProgrammingFile');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runGenerateBitstream;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};

    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.ProgramDevice');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleProgramTargetFPGADevice');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runProgramDevice;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};

    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.GeneratexPCInterface');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleGenerateXPCTargetInterface');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runGeneratexPCInterface;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};

    recordCellArray{end+1}=rec;




    rec=ModelAdvisor.Check('com.mathworks.HDL.FILOption');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleSetFILOptions');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runFILOptions;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.RunFIL');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleBuildFIL');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runFILBuild;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.RunUSRP');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleBuildUSRP');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runUsrpBuild;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};

    rec.InputParametersLayoutGrid=[1,8];
    usrpInputParam={};


    fpgaroot='';


    usrpInputParam{end+1}=ModelAdvisor.InputParameter;
    usrpInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAUsrpSourceFolder');
    usrpInputParam{end}.Type='String';
    usrpInputParam{end}.Value=fpgaroot;
    usrpInputParam{end}.Enable=true;
    usrpInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescUsrpFolder');
    usrpInputParam{end}.setRowSpan([1,1]);
    usrpInputParam{end}.setColSpan([1,7]);


    usrpInputParam{end+1}=ModelAdvisor.InputParameter;
    usrpInputParam{end}.Name='Browse';
    usrpInputParam{end}.Type='PushButton';
    usrpInputParam{end}.Entries=@actionBrowseUsrpFolder;
    usrpInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputDescBrowseUsrp');
    usrpInputParam{end}.setRowSpan([1,1]);
    usrpInputParam{end}.setColSpan([8,8]);

    rec.setInputParameters(usrpInputParam);
    recordCellArray{end+1}=rec;





    rec=ModelAdvisor.Check('com.mathworks.HDL.EmbeddedProject');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleEmbeddedProject');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runCreateEmbeddedProject;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[3,8];
    rec.setInputParametersCallbackFcn(@paramEmbeddedProject);

    epInputParam={};
    paramIdx=0;


    paramIdx=paramIdx+1;
    epInputParam{end+1}=ModelAdvisor.InputParameter;
    epInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAEDKToolName');
    epInputParam{end}.Type='String';
    epInputParam{end}.Value=emtoolValue;
    epInputParam{end}.Enable=false;
    epInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescEDKToolName');
    epInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    epInputParam{end}.setColSpan([1,8]);


    paramIdx=paramIdx+1;
    epInputParam{end+1}=ModelAdvisor.InputParameter;
    epInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAEDKToolFolder');
    epInputParam{end}.Type='String';
    epInputParam{end}.Value=emprojDir;
    epInputParam{end}.Enable=false;
    epInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescEDKToolFolder');
    epInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    epInputParam{end}.setColSpan([1,8]);


    paramIdx=paramIdx+1;
    epInputParam{end+1}=ModelAdvisor.InputParameter;
    epInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAObjective');
    epInputParam{end}.Type='Enum';
    epInputParam{end}.Entries=objectiveList;
    epInputParam{end}.Value=objectiveValue;
    epInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescObjective');
    epInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    epInputParam{end}.setColSpan([1,3]);


    paramIdx=paramIdx+1;
    epInputParam{end+1}=ModelAdvisor.InputParameter;
    epInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAIPCache');
    epInputParam{end}.Type='Bool';
    epInputParam{end}.Value=ipcacheValue;
    epInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescIPCache');
    epInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    epInputParam{end}.setColSpan([1,3]);
    rec.setInputParameters(epInputParam);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.EmbeddedModelGen');
    rec.Title=DAStudio.message('hdlcommon:workflow:HDLWATitleEmbeddedModelGen');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runEmbeddedModelGen;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[2,8];
    rec.setInputParametersCallbackFcn(@paramEmbeddedModelGen);

    epInputParam={};
    paramIdx=0;



    paramIdx=paramIdx+1;

    epInputParam{end+1}=ModelAdvisor.InputParameter;
    epInputParam{end}.Name=DAStudio.message('hdlcommon:workflow:HDLWASWInterfaceModel');
    epInputParam{end}.Type='Bool';
    epInputParam{end}.Value=false;
    epInputParam{end}.Description=DAStudio.message('hdlcommon:workflow:HDLWADescSWInterfaceModel');
    epInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    epInputParam{end}.setColSpan([1,4]);

    epInputParam{end+1}=ModelAdvisor.InputParameter;
    epInputParam{end}.Name=DAStudio.message('hdlcommon:workflow:HDLWAOS');
    epInputParam{end}.Type='Enum';
    epInputParam{end}.Entries=osList;
    epInputParam{end}.Value=osValue;
    epInputParam{end}.Description=DAStudio.message('hdlcommon:workflow:HDLWADescOS');
    epInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    epInputParam{end}.setColSpan([5,8]);



    paramIdx=paramIdx+1;
    epInputParam{end+1}=ModelAdvisor.InputParameter;
    epInputParam{end}.Name=DAStudio.message('hdlcommon:workflow:HDLWAHostTargetInterfaceType');
    epInputParam{end}.Type='Enum';
    epInputParam{end}.Entries=hostInterfaceList;
    epInputParam{end}.Value=hostInterfaceValue;
    epInputParam{end}.Description=DAStudio.message('hdlcommon:workflow:HDLWADescHostInterface');
    epInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    epInputParam{end}.setColSpan([1,4]);


    paramIdx=paramIdx+1;
    epInputParam{end+1}=ModelAdvisor.InputParameter;
    epInputParam{end}.Name=DAStudio.message('hdlcommon:workflow:HDLWAHostInterfaceModel');
    epInputParam{end}.Type='Bool';
    epInputParam{end}.Value=false;
    epInputParam{end}.Description=DAStudio.message('hdlcommon:workflow:HDLWADescHostInterfaceModel');
    epInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    epInputParam{end}.setColSpan([1,4]);


    paramIdx=paramIdx+1;
    epInputParam{end+1}=ModelAdvisor.InputParameter;
    epInputParam{end}.Name=DAStudio.message('hdlcommon:workflow:HDLWASWInterfaceScript');
    epInputParam{end}.Type='Bool';
    epInputParam{end}.Value=false;
    epInputParam{end}.Description=DAStudio.message('hdlcommon:workflow:HDLWADescSWInterfaceScript');
    epInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    epInputParam{end}.setColSpan([1,4]);

    rec.setInputParameters(epInputParam);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.EmbeddedCustomModelGen');
    rec.Title=DAStudio.message('hdlcommon:workflow:HDLWATitleEmbeddedCustomModelGen');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runEmbeddedModelGen;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[2,8];
    rec.setInputParametersCallbackFcn(@paramEmbeddedModelGen);

    epInputParam={};
    paramIdx=0;


    paramIdx=paramIdx+1;
    epInputParam{end+1}=ModelAdvisor.InputParameter;
    epInputParam{end}.Name=DAStudio.message('hdlcommon:workflow:HDLWASWInterfaceModel');
    epInputParam{end}.Type='Bool';
    epInputParam{end}.Value=false;
    epInputParam{end}.Description=DAStudio.message('hdlcommon:workflow:HDLWATitleEmbeddedCustomModelGen');
    epInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    epInputParam{end}.setColSpan([1,8]);

    rec.setInputParameters(epInputParam);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.EmbeddedSystemBuild');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleEmbeddedSystemBuild');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runEmbeddedSystemBuild;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[10,8];
    rec.setInputParametersCallbackFcn(@paramEmbeddedSystemBuild);

    ebInputParam={};
    paramIdx=0;


    paramIdx=paramIdx+1;
    ebInputParam{end+1}=ModelAdvisor.InputParameter;
    ebInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAEDKExternal');
    ebInputParam{end}.Type='Bool';
    ebInputParam{end}.Value=emexbValue;
    ebInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescEDKExternal');
    ebInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ebInputParam{end}.setColSpan([1,8]);


    paramIdx=paramIdx+1;
    ebInputParam{end+1}=ModelAdvisor.InputParameter;
    ebInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAEnableDefaultBuildTcl');
    ebInputParam{end}.Type='Enum';
    ebInputParam{end}.Entries={'Default','Custom'};
    ebInputParam{end}.Value='Default';
    ebInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescEnableDefaultBuildTcl');
    ebInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ebInputParam{end}.setColSpan([1,3]);

    ebInputParam{end+1}=ModelAdvisor.InputParameter;
    ebInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWASpecifyCustomBuildTcl');
    ebInputParam{end}.Type='String';
    ebInputParam{end}.Value=customBuildTcl;
    ebInputParam{end}.Enable=false;
    ebInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescCustomTcl');
    ebInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ebInputParam{end}.setColSpan([4,7]);


    ebInputParam{end+1}=ModelAdvisor.InputParameter;
    ebInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWACustomTclBrowse');
    ebInputParam{end}.Type='PushButton';
    ebInputParam{end}.Entries=@actionBrowseCustomTcl;
    ebInputParam{end}.Enable=false;
    ebInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescCustomTclBrowse');
    ebInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ebInputParam{end}.setColSpan([8,8]);


    paramIdx=paramIdx+1;
    ebInputParam{end+1}=ModelAdvisor.InputParameter;
    ebInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAEnableDesignCheckpoint');
    ebInputParam{end}.Type='Bool';
    ebInputParam{end}.Value=designCheckpointEnb;
    ebInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAEnableDesignCheckpointStr');
    ebInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ebInputParam{end}.setColSpan([1,3]);


    paramIdx=paramIdx+1;
    ebInputParam{end+1}=ModelAdvisor.InputParameter;
    ebInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAEnableDefaultCheckpointFile');
    ebInputParam{end}.Type='Enum';
    ebInputParam{end}.Entries={'Default','Custom'};
    ebInputParam{end}.Enable=false;
    ebInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescEnableDefaultCheckpointFile');
    ebInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ebInputParam{end}.setColSpan([1,4]);

    paramIdx=paramIdx+1;
    ebInputParam{end+1}=ModelAdvisor.InputParameter;
    ebInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAEnableDesignCheckpointFile');
    ebInputParam{end}.Type='String';
    ebInputParam{end}.Value=designCheckpointFileEnb;
    ebInputParam{end}.Enable=false;
    ebInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAEnableDesignCheckpointFileStr');
    ebInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ebInputParam{end}.setColSpan([1,7]);


    ebInputParam{end+1}=ModelAdvisor.InputParameter;
    ebInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAEnableDesignCheckpointFileBrowse');
    ebInputParam{end}.Type='PushButton';
    ebInputParam{end}.Entries=@actionBrowseDesignCheckpointFile;
    ebInputParam{end}.Enable=false;
    ebInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAEnableDesignCheckpointFileBrowseStr');
    ebInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ebInputParam{end}.setColSpan([8,8]);


    paramIdx=paramIdx+1;
    ebInputParam{end+1}=ModelAdvisor.InputParameter;
    ebInputParam{end}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAInputNoOfCores');
    ebInputParam{end}.Type='Enum';
    ebInputParam{end}.Entries={'synthesis tool default','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32'};
    ebInputParam{end}.Value=maxNumOfCores;
    ebInputParam{end}.Description=DAStudio.message('HDLShared:hdldialog:HDLWAInputNoOfCoresValueDesc');
    ebInputParam{end}.setRowSpan([paramIdx,paramIdx]);
    ebInputParam{end}.setColSpan([1,4]);

    rec.setInputParameters(ebInputParam);
    recordCellArray{end+1}=rec;


    rec=ModelAdvisor.Check('com.mathworks.HDL.EmbeddedDownload');
    rec.Title=DAStudio.message('HDLShared:hdldialog:HDLWATitleProgramTargetFPGADevice');
    rec.TitleTips=rec.Title;
    rec.CallbackHandle=@runEmbeddedDownload;
    rec.CallbackContext='None';
    rec.CallbackStyle='StyleThree';
    rec.Value=true;
    rec.LicenseName={'Simulink_HDL_Coder'};
    rec.InputParametersLayoutGrid=[1,8];
    rec.setInputParametersCallbackFcn(@paramEmbeddedDownload);

    edInputParam={};
    paramIdx=0;


    paramIdx=paramIdx+1;
    edInputParam{paramIdx}=ModelAdvisor.InputParameter;
    edInputParam{paramIdx}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAProgrammingMethod');
    edInputParam{paramIdx}.Type='Enum';
    edInputParam{paramIdx}.Entries=cell(programList);
    edInputParam{paramIdx}.Value=programValue;
    edInputParam{paramIdx}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescProgrammingMethod');
    edInputParam{paramIdx}.setRowSpan([paramIdx,paramIdx]);
    edInputParam{paramIdx}.setColSpan([1,4]);


    paramIdx=paramIdx+1;
    edInputParam{paramIdx}=ModelAdvisor.InputParameter;
    edInputParam{paramIdx}.Name=DAStudio.message('HDLShared:hdldialog:HDLWAIPAddress');
    edInputParam{paramIdx}.Type='String';
    edInputParam{paramIdx}.Value=ipAddr;
    edInputParam{paramIdx}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescIPAddress');
    edInputParam{paramIdx}.setRowSpan([paramIdx,paramIdx]);
    edInputParam{paramIdx}.setColSpan([1,4]);


    paramIdx=paramIdx+1;
    edInputParam{paramIdx}=ModelAdvisor.InputParameter;
    edInputParam{paramIdx}.Name=DAStudio.message('HDLShared:hdldialog:HDLWASSHUsername');
    edInputParam{paramIdx}.Type='String';
    edInputParam{paramIdx}.Value=sshUsername;
    edInputParam{paramIdx}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescSSHUsername');
    edInputParam{paramIdx}.setRowSpan([paramIdx,paramIdx]);
    edInputParam{paramIdx}.setColSpan([1,4]);


    paramIdx=paramIdx+1;
    edInputParam{paramIdx}=ModelAdvisor.InputParameter;
    edInputParam{paramIdx}.Name=DAStudio.message('HDLShared:hdldialog:HDLWASSHPassword');
    edInputParam{paramIdx}.Type='String';
    edInputParam{paramIdx}.Value=sshPassword;
    edInputParam{paramIdx}.Description=DAStudio.message('HDLShared:hdldialog:HDLWADescSSHPassword');
    edInputParam{paramIdx}.setRowSpan([paramIdx,paramIdx]);
    edInputParam{paramIdx}.setColSpan([1,4]);

    rec.setInputParameters(edInputParam);
    recordCellArray{end+1}=rec;


    hWorkflowList=hdlworkflow.getWorkflowList;
    recordCellArray=hWorkflowList.defineHDLWorkflowAdvisorChecks(recordCellArray,@publishFailedMessage,@publishResults,@utilDisplayResult);






