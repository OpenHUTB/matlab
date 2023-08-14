



classdef DownstreamIntegrationDriver<matlab.mixin.SetGetExactNames


    properties


        hCodeGen=[];


        hToolDriver=[];
        hSimulationToolDriver=[];


        hTurnkey=[];


        hGeneric=[];


        hIP=[];


        Workflow=[];
        Board=[];
        Tool=[];
        SimulationTool=[];



        hWorkflowConfig=[];


        EnableTestpointsSetting=[];


        Objective=hdlcoder.Objective.None;


        GenerateRTLCode=true;
        GenerateTestbench=false;
        GenerateValidationModel=false;


        SkipPreRouteTimingAnalysis=false;
        IgnorePlaceAndRouteErrors=false;
        SkipPlaceAndRoute=true;
        SkipVerifyCosim=false;


        CustomBuildTclFile='';
        TclFileForSynthesisBuild='Default';
        EnableDesignCheckpoint=false;
        RoutedDesignCheckpointFilePath='';
        DefaultCheckpointFile='Default';
        MaxNumOfCoresForBuild='';


        CriticalPathSource='pre-route';
        CriticalPathNumber='1';
        ShowAllPaths=false;
        ShowDelayData=true;
        ShowUniquePaths=false;
        ShowEndsOnly=false;


        hAvailableBoardList=[];
        hAvailableToolList=[];
        hAvailableSimulationToolList=[];
        hFilBuildInfo=[];
        hFilWizardDlg=[];

        turnkeyboardloaded=false;
        xpcboardloaded=false;
        turnkeyhandleset=false;
        xpchandleset=false;

        handleTurnkey=[];
        handleXPC=[];


        ToolName=[];


        cmdDisplay=false;
        cliDisplay=false;
        logDisplay=false;
        debugMode=false;



        queryFlowOnly=false;

        codesignflag=false;


        isMLHDLC=false;


        isMDS=false;


        hdlWFSbMap=[];



        keepCodegenDir=false;


        transientCLIMaps=[];









        hWorkflowList=[];




























        havePIM=false;
        pim=[];





        AllowUnsupportedToolVersion=false;



        hWCProjectFolder='';





Verbosity

    end

    properties(Access=private)

        ProjectFolder='';
        errorModelSetting=false;
        loadingFromModel=false;
    end

    properties(Constant,Hidden=true)
        defaultProjectFolderSL='hdl_prj';
        defaultProjectFolderML='codegen';
        filDir='fil_prj';
        usrpDir='usrp_prj';

        sdrDir='sdr_prj';

        iseDir='ise_prj';
        vivadoDir='vivado_prj';
        quartusDir='quartus_prj';
        liberoDir='libero_prj';
        intelquartusproDir='qpro_prj';
        hdlDir='hdlsrc';
        GenericWorkflowStr='Generic ASIC/FPGA';
        FILWorkflowStr='FPGA-in-the-Loop';
        TurnkeyWorkflowStr='FPGA Turnkey';
        HLSWorkflowStr='High Level Synthesis';
        XPCWorkflowStr='Simulink Real-Time FPGA I/O';
        IPWorkflowStr='IP Core Generation';
        DLWorkflowStr='Deep Learning Processor';
        USRPWorkflowStr='Customization for the USRP(R) Device';

        SDRWorkflowStr='Customization for an SDR Platform';

        AddNewBoardStr='Create custom board...';
        GetMoreStr='Get more...';
        GetMoreBoardStr='Get more boards...';
        EmptyBoardStr='Choose a platform';
    end

    properties(Hidden=true)

        tclOnly=false;
        tclOnlyTool='';
        buildFPGAOptions=[];


        CoProcessorModeFeatureOn=false;
    end

    properties(Constant,Hidden=true)

        EmptyToolStr='No synthesis tool specified';
        NoAvailableToolStr='No synthesis tool available on system path';
        NoAvailableSimToolStr='No simulation tool available on system path';
    end


    methods(Access=public)

        function obj=DownstreamIntegrationDriver(modelName,cmdDisplay,tclOnly,tclOnlyTool,queryFlow,hdlDrv,isMLHDLC,iscdflag,keepCodegenDir,cliDisplay,projFolder,verbosity)


            if nargin<12
                verbosity=0;
            end

            if nargin<11
                projFolder='';
            end

            if nargin<10
                cliDisplay=false;
            end

            if nargin<9
                keepCodegenDir=false;
            end

            if nargin<8
                iscdflag=false;
            end
            if nargin<7
                isMLHDLC=false;
            end

            if nargin<6
                hdlDrv=[];
            end

            if nargin<5
                queryFlow=downstream.queryflowmodesenum.NONE;
            end

            if nargin<4
                tclOnlyTool='';
            end
            if nargin<3
                tclOnly=false;
            end
            if nargin<2
                cmdDisplay=false;
            end


            obj.cmdDisplay=cmdDisplay;
            obj.tclOnly=tclOnly;
            obj.tclOnlyTool=tclOnlyTool;
            obj.queryFlowOnly=queryFlow;
            obj.isMLHDLC=isMLHDLC;
            obj.codesignflag=iscdflag;
            obj.keepCodegenDir=keepCodegenDir;
            obj.cliDisplay=cliDisplay;
            obj.Verbosity=verbosity;









            obj.hWorkflowList=hdlworkflow.getWorkflowList('reload');


            obj.hAvailableToolList=downstream.AvailableToolList(obj);
            obj.hAvailableSimulationToolList=downstream.AvailableSimulationToolList;









            if~isempty(projFolder)
                obj.hWCProjectFolder=projFolder;
            end


            if isMLHDLC
                obj.ProjectFolder=obj.defaultProjectFolderML;
            else
                if obj.queryFlowOnly==downstream.queryflowmodesenum.NONE
                    obj.ProjectFolder=obj.defaultProjectFolderSL;
                else
                    obj.ProjectFolder=obj.queryFlowOnly.getDefaultProjectFolder(hdlDrv,obj.defaultProjectFolderSL);
                end
            end
            obj.hToolDriver=downstream.ToolDriver(obj);
            obj.hSimulationToolDriver=downstream.SimulationToolDriver(obj);


            obj.hFilWizardDlg=[];
            obj.hFilBuildInfo=[];





            switch obj.queryFlowOnly
            case downstream.queryflowmodesenum.NONE

                obj.hCodeGen=downstream.CodeGenInfo(obj,modelName,hdlDrv);


                obj.hTurnkey=hdlturnkey.TurnkeyDriver(obj);


                obj.hGeneric=downstream.GenericDriver(obj);


                obj.hCodeGen.hCHandle.DownstreamIntegrationDriver=obj;
            case downstream.queryflowmodesenum.MATLAB
                obj.queryFlowOnly.createHDISetup(obj,'modelName',modelName);
            case downstream.queryflowmodesenum.VIVADOSYSGEN
                obj.queryFlowOnly.createHDISetup(obj,'modelName',modelName,...
                'hdlDrv',hdlDrv);
            end


            obj.hAvailableBoardList=[];


            obj.hIP=[];


            if obj.codesignflag
                obj.Workflow=downstream.Option('Target','Workflow',obj.IPWorkflowStr);
            else
                obj.Workflow=downstream.Option('Target','Workflow',obj.GenericWorkflowStr);
            end

            obj.Board=downstream.Option('Target','Board','');
            obj.Tool=downstream.Option('Target','Tool',obj.getInitToolStr);
            obj.ToolName=downstream.Option('Target','ToolName',obj.getInitToolStr);

            obj.SimulationTool=downstream.Option('Target','SimulationTool',obj.getInitSimToolStr);
            obj.turnkeyboardloaded=false;
            obj.xpcboardloaded=false;

            if obj.codesignflag
                obj.setWorkflowName(obj.IPWorkflowStr);
            end


            obj.hdlWFSbMap=containers.Map('KeyType','char','ValueType','any');


            obj.loadDefaultTool;



            obj.loadTargetWorkflow(modelName);

            if obj.isDynamicWorkflow





                workflow=obj.get('workflow');
                hWorkflowList=hdlworkflow.getWorkflowList;
                hWorkflow=hWorkflowList.getWorkflow(workflow);
                hWorkflow.loadModelSettings(modelName);
            else
                obj.loadModelSettings(modelName);
            end


            obj.populateTransientCLIMaps;


            if obj.queryFlowOnly~=downstream.queryflowmodesenum.NONE
                obj.queryFlowOnly.postCreateHDISetup(obj);
            end
        end


        loadModelSettings(obj,modelName)
        loadGenerateHDLSettingsFromModel(obj,modelName,loadTBSettings)
        populateTransientCLIMaps(obj)
        emitLoadingErrorMsg(obj,modelName,msg)
        savetargetDeviceSettingToModel(obj,modelName,workflow,targetPlatform,synthesisTool,synthesisToolChipFamily,synthesisToolDeviceName,synthesisToolPackageName,synthesisToolSpeedValue)
        saveCustomFileSettingToModel(obj,modelName,customFiles)
        saveRDSettingToModel(obj,modelName,referenceDesign)
        saveSyncModeSettingToModel(obj,modelName,syncMode)
        saveTestPointSettingToModel(obj,modelName,enableTestPoints)
        saveGenerateHDLSettingToModel(obj,modelName,generateHDLCode,generateTestbench,generateValidationModel)
        saveIpCoreNameToModel(obj,modelName,ipCoreName)
        saveIpCoreVersionToModel(obj,modelName,ipCoreVersion)
        saveIpAXISlaveIDWidthToModel(obj,modelName,AXISlaveIDWidth)
        saveIpCoreAdditionalSourceFileToModel(obj,modelName,additionalSourceFile)
        saveIpCoreDataCaptureBufferSizeToModel(obj,modelName,bufferSize)
        saveIpCoreDataCaptureSequenceDepthToModel(obj,modelName,sequenceDepth)
        saveIpCoreDataCaptureIncludeCaptureControlToModel(obj,modelName,captureControlEnable)
        saveIpCoreAXI4RegisterReadbackToModel(obj,modelName,setAXI4RegisterReadback)
        saveAXI4SlavePortToPipelineRegisterRatioToModel(obj,modelName,setAXI4SlavePortToPipelineRegisterRatio)
        saveIpCoreDUTClockEnableToModel(obj,modelName,DUTClockEnPort)
        saveIpCoreDUTCEOutToModel(obj,modelName,DUTCEOutPort)
        errorModelSetting=geterrorModelSetting(obj)
        loadingFromModel=getloadingFromModel(obj)
        setloadingFromModel(obj,value)
        labelerrorModelSetting(obj)
        addhdlWFSbMap(obj,key,value)
        hdlWFSbMap=gethdlWFSbMap(obj)


        setToolForBoard(obj,boardName)



        setFPGAParts(obj,FPGAFamily,FPGADevice,FPGAPackage,FPGASpeed,boardName)


        setCustomToolPath(obj,userToolPath)
        toolPath=getCustomToolPath(obj)


        mdlName=getModelName(obj)
        dutName=getDutName(obj)

        function setAllowUnsupportedToolVersion(obj,ignoreOption)
            obj.AllowUnsupportedToolVersion=ignoreOption;
        end

        function allowOption=getAllowUnsupportedToolVersion(obj)
            allowOption=obj.AllowUnsupportedToolVersion;
        end
    end

    methods(Access=protected)



        initBoard(obj,boardName)


        loadTurnkeyBoard(obj,boardName)

        loadIPPlatform(obj,boardName)

        loadFILBoard(obj,boardName)

        loadUSRPBoard(obj,boardName)
        setWorkflowName(obj,targetName)

        setBoardName(obj,boardName)
        setBoardValue(obj,boardName)
        boardNameList=getBoardNameList(obj)
        workflowList=getTargetWorkflowList(obj)
        requiredToolList=getRequiredTool(obj,boardName)

        requiredToolVersionList=getRequiredToolVersion(obj,boardName)

        isIn=isToolInBoardRequiredToolList(obj,toolName,boardName)

        availToolList=getAvailableToolForBoard(obj,boardName)


        [FPGAFamily,FPGADevice,FPGAPackage,FPGASpeed]=getFPGAParts(obj)

        reportUnsupportedDevice(obj,FPGAFamily,FPGADevice,FPGAPackage,FPGASpeed,boardName)
        setupToolMsg=printSetupToolMsg(obj)



        loadTool(obj,toolName)

        loadDefaultTool(obj)


        setToolName(obj,toolName)

        toolNameList=getToolNameList(obj)

        initToolStr=getInitToolStr(obj)

        initToolStr=getInitSimToolStr(obj)

        toolNameList=getSimToolNameList(obj)
    end


    methods(Access=public)

        refreshToolList(obj)

        openTargetTool(obj)

        version=getToolVersion(obj)


        value=getProjectPath(obj)
        setProjectPath(obj,value)

        value=getCustomHDLFile(obj)
        setCustomHDLFile(obj,value)

        value=getCustomTclFile(obj)
        setCustomTclFile(obj,value)
        result=isGenericWorkflow(obj)
        result=isHLSWorkflow(obj)
        result=isFILWorkflow(obj)
        result=isTurnkeyWorkflow(obj)
        result=isXPCWorkflow(obj)
        result=isUSRPWorkflow(obj)
        result=isSDRWorkflow(obj)
        result=isPluginWorkflow(obj,varargin)
        result=isIPWorkflow(obj)
        result=isDLWorkflow(obj)

        result=isBoardEmpty(obj)

        ret=isFILBoardLoaded(obj)

        ret=isBoardLoaded(obj)
        result=isXilinxIP(obj)
        result=isAlteraIP(obj)
        result=isVivado(obj)
        result=isQuartus(obj)
        result=isISE(obj)

        result=isTestPointEnabledOnModel(obj)

        result=isCosimEnabledOnModel(obj)
        result=isSVDPIEnabledOnModel(obj)

        toolName=getToolName(obj)

        result=isToolEmpty(obj)
        setToolEmpty(obj)

        result=isNoToolAvailable(obj,toolName)
        result=isxPCTargetBoard(obj)
        result=isGenericIPPlatform(obj)

        result=isShowTargetFrequencyTask(obj)
        result=isShowGenericTargetFrequencyTask(obj)

        result=showReferenceDesignTasks(obj)
        result=showEmbeddedTasks(obj)

        timingPath=getPostMapTimingReportPath(obj)
        timingPath=getPostPARTimingReportPath(obj)
        timingPath=getPARReportPath(obj)

        result=isProcessingSystemAvailable(obj)
        [isInstalled,spName]=isHDLCoderSoCSPInstalled(obj)
        [isInstalled,spName]=isEmbeddedCoderSPInstalled(obj)

        status=getStatus(obj)
        resetStatus(obj)
        setStatus(obj,workflowID)
        filename=getTclFileName(obj)
        skipWorkflow(obj,workflowID)
        unskipWorkflow(obj,workflowID)

        setProjectFolder(obj,folder)
        createProjectFolder(obj,folder)


        updateCodegenAndPrjDir(obj)
        folder=getProjectFolder(obj)

        validateCell=validateProjectFolder(obj,folder)

        fulldir=getFullFILDir(obj)
        fulldir=getFullUsrpDir(obj)
        fulldir=getFullSDRDir(obj)
        fulldir=getFullFPGADir(obj)
        reldir=getRelativeFPGADir(obj)
        fulldir=getFullHdlsrcDir(obj)


        mcsFilePath=getMCSFilePath(obj)
        mcsFileName=getMCSFileName(obj)

        setTargetInterface(obj,portName,interfaceStr)
        interfaceStr=getTargetInterface(obj,portName)
        setTargetOffset(obj,portName,offsetStr)
        offsetStr=getTargetOffset(obj,portName)
        initTargetInterface(obj)
        dispTargetInterface(obj)
        validateCell=validateTargetInterface(obj)
        isa=isInterfaceTableNeeded(obj)

        logTxt=setTargetFrequency(obj,clockFreq)
        clockFreq=getTargetFrequency(obj)

        runTurnkeyCodeGen(obj)

        runTurnkeySynthesis(obj)

        [status,result]=runFILBuild(obj)

        pluginPath=getPluginPath(obj)


        validateCell=runIPCoreCodeGen(obj)
        [status,result]=runCreateEmbeddedProject(obj)
        [status,result,validateCell]=runSWInterfaceGen(obj)
        [status,result,validateCell]=runEmbeddedSystemBuild(obj)
        [status,result,validateCell]=runEmbeddedDownloadBitstream(obj)
    end


    methods(Access=public,Hidden=true)

        isOn=showExecutionMode(obj)
        isQueryFlow=isQueryFlowOnly(obj)
    end


    methods(Access=public)

        disp(obj,varargin)
        getdisp(obj)
        setdisp(obj)

        varargout=get(obj,varargin)
        varargout=set(obj,varargin)

        hOption=getOption(obj,optionID)
        hWorkflow=getWorkflow(obj,workflowID)

        [status,result,warnMsg,hardwareResults]=run(obj,varargin)
        [status,result]=runHLSSynthesis(obj)

        generateVitisProjectTclFile(obj,vitisHLSPrjName,stage)
    end

    methods(Access=protected)

        choice=getOptionChoice(obj,optionID)
        setOptionValue(obj,optionID,optionValue)
        optionValue=getOptionValue(obj,optionID)

        workflowID=dispWorkflowID(obj,workflowID,hOption,optionWidth)

        dispButton(obj)

        optionList=getOptionList(obj)

        validateBoardLoaded(obj)
    end

    methods(Access=private)


        hardwareResults=parseToolReports(obj,varargin);
    end

    methods(Static)

        openStratusProject(obj);

        openVitisHLSPrj(obj);
    end
end


function requiredList=l_getRequiredToolListSDR(boardName)

    isSDRF=(exist('sdrfroot.m','file')==2);
    isSDRZ=(exist('sdrzroot.m','file')==2);

    if(isSDRF||isSDRZ)
        requiredList=(sdr.internal.hdlwa.driverGetRequiredToolList(boardName));
    end
end






