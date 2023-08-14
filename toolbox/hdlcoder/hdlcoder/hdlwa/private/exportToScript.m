function exportToScript






    MAObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    modelName=MAObj.modelName;
    hdriver=hdlmodeldriver(modelName);
    hDI=hdriver.DownstreamIntegrationDriver;


    tool=hDI.get('Tool');
    workflow=hDI.get('Workflow');

    hWorkflowList=hdlworkflow.getWorkflowList;
    isDynamicWorkflowLoaded=hWorkflowList.isInWorkflowList(workflow);

    isGeneric=strcmp(workflow,'Generic ASIC/FPGA');
    isTurnkey=strcmp(workflow,'FPGA Turnkey');
    isIPCore=strcmp(workflow,'IP Core Generation');
    isSLRT=strcmp(workflow,'Simulink Real-Time FPGA I/O');
    isFIL=strcmp(workflow,'FPGA-in-the-Loop');

    if(~(isGeneric||isTurnkey||isIPCore||isSLRT||isFIL||isDynamicWorkflowLoaded))
        hf=errordlg(...
        DAStudio.message('hdlcoder:workflow:WorkflowNotValidExport',workflow),...
        DAStudio.message('hdlcoder:workflow:WorkflowNotValidExportTitle'),...
        'modal');
        set(hf,'tag','HDL Workflow Advisor error dialog');
        uiwait(hf);
        return;
    end

    isVivado=strcmp(tool,'Xilinx Vivado');
    isISE=strcmp(tool,'Xilinx ISE');
    isQuartus=strcmp(tool,'Altera QUARTUS II');
    isLiberoSoC=strcmp(tool,'Microchip Libero SoC');
    isQuartusPro=strcmp(tool,'Intel Quartus Pro');



    if(~(isVivado||isISE||isQuartus||isLiberoSoC||isQuartusPro||isDynamicWorkflowLoaded))
        hf=errordlg(...
        DAStudio.message('hdlcoder:workflow:InvalidSynthesisToolExport',tool),...
        DAStudio.message('hdlcoder:workflow:InvalidSynthesisToolExportTitle'),...
        'modal');
        set(hf,'tag','HDL Workflow Advisor error dialog');
        uiwait(hf);
        return;
    end

    if isDynamicWorkflowLoaded
        hWorkflow=hWorkflowList.getWorkflow(workflow);
        hWC=hdlcoder.WorkflowConfig('SynthesisTool',tool,'TargetWorkflow',workflow);
        hWorkflow.setWorkflowTasks(hWC,hDI);
        hdlwa.hdlwa_exportToScript(hWC);
        return;
    end


    hWC=hdlcoder.WorkflowConfig('SynthesisTool',tool,'TargetWorkflow',workflow);
    hWC.ProjectFolder=hDI.getProjectFolder;
    hWC.Objective=hDI.getObjectiveObject;
    hWC.AllowUnsupportedToolVersion=hDI.AllowUnsupportedToolVersion;

    switch(workflow)
    case 'Generic ASIC/FPGA'
        hWC.GenerateRTLCode=hDI.GenerateRTLCode;
        hWC.GenerateTestbench=hDI.GenerateTestbench;
        hWC.GenerateValidationModel=hDI.GenerateValidationModel;

        hWC.AdditionalProjectCreationTclFiles=hDI.getCustomTclFile;
        hWC.SkipPreRouteTimingAnalysis=hDI.SkipPreRouteTimingAnalysis;
        hWC.IgnorePlaceAndRouteErrors=hDI.IgnorePlaceAndRouteErrors;
        hWC.CriticalPathSource=hDI.CriticalPathSource;
        hWC.CriticalPathNumber=hDI.CriticalPathNumber;
        hWC.ShowAllPaths=hDI.ShowAllPaths;
        hWC.ShowDelayData=hDI.ShowDelayData;
        hWC.ShowUniquePaths=hDI.ShowUniquePaths;
        hWC.ShowEndsOnly=hDI.ShowEndsOnly;


        hWC.setAllTasks;

        if~strcmpi(hdlget_param(modelName,'GenerateCoSimModel'),'none')
            if(hDI.SkipVerifyCosim)
                hWC.RunTaskVerifyWithHDLCosimulation=false;
            else
                hWC.RunTaskVerifyWithHDLCosimulation=true;
            end
        else
            hWC.RunTaskVerifyWithHDLCosimulation=false;
        end
        if(hDI.SkipPlaceAndRoute)
            if(isVivado||isLiberoSoC)
                hWC.RunTaskRunImplementation=false;
            else
                hWC.RunTaskPerformPlaceAndRoute=false;
            end
        end
    case 'FPGA Turnkey'

        hWC.AdditionalProjectCreationTclFiles=hDI.getCustomTclFile;
        hWC.SkipPreRouteTimingAnalysis=hDI.SkipPreRouteTimingAnalysis;
        hWC.IgnorePlaceAndRouteErrors=hDI.IgnorePlaceAndRouteErrors;


        hWC.setAllTasks;

        if(hDI.SkipPlaceAndRoute)
            if(isVivado)
                hWC.RunTaskRunImplementation=false;
            else
                hWC.RunTaskPerformPlaceAndRoute=false;
            end
            hWC.RunTaskGenerateProgrammingFile=false;
            hWC.RunTaskProgramTargetDevice=false;
        end
    case 'Simulink Real-Time FPGA I/O'

        if(hDI.isIPCoreGen)
            hWC.ReferenceDesignToolVersion=hDI.hIP.getRDToolVersion;
            hWC.IgnoreToolVersionMismatch=hDI.hIP.getIgnoreRDToolVersionMismatch;
            hWC.GenerateIPCoreReport=hDI.hIP.getIPCoreReportStatus;
            hWC.IPCoreRepository=hDI.hIP.getIPRepository;
            hWC.RunExternalBuild=hDI.hIP.getEmbeddedExternalBuild;
            hWC.EnableDesignCheckpoint=hDI.getEnableDesignCheckpoint;
            hWC.MaxNumOfCoresForBuild=hDI.getMaxNumOfCores;
            hWC.OperatingSystem=hDI.hIP.getOperatingSystem;
            hWC.EnableIPCaching=hDI.hIP.getUseIPCache;

            hWC.ReportTimingFailure=hDI.hIP.getReportTimingFailure;
            hWC.ReportTimingFailureTolerance=hDI.hIP.getReportTimingFailureTolerance;

            if(strcmp(hDI.getTclFileForSynthesisBuild,'Custom'))
                hWC.TclFileForSynthesisBuild=hdlcoder.BuildOption.Custom;
                hWC.CustomBuildTclFile=hDI.getCustomBuildTclFile;
            else
                hWC.TclFileForSynthesisBuild=hdlcoder.BuildOption.Default;
            end

            if((hWC.EnableDesignCheckpoint)&&(strcmp(hDI.getDefaultCheckpointFile,'Custom')))
                hWC.DefaultCheckpointFile='Custom';
                hWC.RoutedDesignCheckpointFilePath=hDI.getRoutedDesignCheckpointFilePath;
            elseif(~hWC.EnableDesignCheckpoint&&(strcmp(hDI.getDefaultCheckpointFile,'Custom')))
                hWC.DefaultCheckpointFile='Custom';
                hWC.RoutedDesignCheckpointFilePath='';
            elseif(~hWC.EnableDesignCheckpoint&&(strcmp(hDI.getDefaultCheckpointFile,'Default')))
                hWC.DefaultCheckpointFile='Default';
                hWC.RoutedDesignCheckpointFilePath='';
            else
                hWC.DefaultCheckpointFile='Default';
                hWC.RoutedDesignCheckpointFilePath=hDI.hIP.getIPCoreDesignCheckpointFile;
            end


            hWC.setAllTasks;
        else
            hWC.AdditionalProjectCreationTclFiles=hDI.getCustomTclFile;
            hWC.SkipPreRouteTimingAnalysis=hDI.SkipPreRouteTimingAnalysis;
            hWC.IgnorePlaceAndRouteErrors=hDI.IgnorePlaceAndRouteErrors;


            hWC.setAllTasks;
        end

    case 'IP Core Generation'
        hWC.ReferenceDesignToolVersion=hDI.hIP.getRDToolVersion;
        hWC.IgnoreToolVersionMismatch=hDI.hIP.getIgnoreRDToolVersionMismatch;
        hWC.GenerateIPCoreReport=hDI.hIP.getIPCoreReportStatus;
        hWC.IPCoreRepository=hDI.hIP.getIPRepository;
        hWC.RunExternalBuild=hDI.hIP.getEmbeddedExternalBuild;
        hWC.EnableDesignCheckpoint=hDI.getEnableDesignCheckpoint;
        hWC.MaxNumOfCoresForBuild=hDI.getMaxNumOfCores;
        hWC.OperatingSystem=hDI.hIP.getOperatingSystem;
        hWC.ProgrammingMethod=hDI.hIP.getProgrammingMethod;
        hWC.EnableIPCaching=hDI.hIP.getUseIPCache;
        hWC.HostTargetInterface=hDI.hIP.getHostTargetInterface;
        hWC.GenerateHostInterfaceModel=hDI.hIP.GenerateHostInterfaceModel;
        hWC.GenerateHostInterfaceScript=hDI.hIP.GenerateHostInterfaceScript;
        hWC.GenerateSoftwareInterfaceModel=hDI.hIP.GenerateSoftwareInterfaceModel;


        hWC.ReportTimingFailure=hDI.hIP.getReportTimingFailure;
        hWC.ReportTimingFailureTolerance=hDI.hIP.getReportTimingFailureTolerance;

        if(strcmp(hDI.getTclFileForSynthesisBuild,'Custom'))
            hWC.TclFileForSynthesisBuild=hdlcoder.BuildOption.Custom;
            hWC.CustomBuildTclFile=hDI.getCustomBuildTclFile;
        else
            hWC.TclFileForSynthesisBuild=hdlcoder.BuildOption.Default;
        end


        if((hWC.EnableDesignCheckpoint)&&(strcmp(hDI.getDefaultCheckpointFile,'Custom')))
            hWC.DefaultCheckpointFile='Custom';
            hWC.RoutedDesignCheckpointFilePath=hDI.getRoutedDesignCheckpointFilePath;
        elseif(~hWC.EnableDesignCheckpoint&&(strcmp(hDI.getDefaultCheckpointFile,'Custom')))
            hWC.DefaultCheckpointFile='Custom';
            hWC.RoutedDesignCheckpointFilePath='';
        elseif(~hWC.EnableDesignCheckpoint&&(strcmp(hDI.getDefaultCheckpointFile,'Default')))
            hWC.DefaultCheckpointFile='Default';
            hWC.RoutedDesignCheckpointFilePath='';
        else
            hWC.DefaultCheckpointFile='Default';
            hWC.RoutedDesignCheckpointFilePath=hDI.hIP.getIPCoreDesignCheckpointFile;
        end


        hWC.setAllTasks;
        if(hDI.isGenericIPPlatform)
            hWC.RunTaskCreateProject=false;
            hWC.RunTaskBuildFPGABitstream=false;
            hWC.RunTaskGenerateSoftwareInterface=false;
            hWC.RunTaskProgramTargetDevice=false;
        else

            if(hWC.RunExternalBuild)
                hWC.RunTaskProgramTargetDevice=false;
            end
        end
    case 'FPGA-in-the-Loop'
        hWC.GenerateRTLCode=hDI.GenerateRTLCode;
        hWC.GenerateTestbench=hDI.GenerateTestbench;
        hWC.GenerateValidationModel=hDI.GenerateValidationModel;

        if~strcmpi(hdlget_param(modelName,'GenerateCoSimModel'),'none')
            if hDI.SkipVerifyCosim||hWC.GenerateTestbench==false
                hWC.RunTaskVerifyWithHDLCosimulation=false;
            else
                hWC.RunTaskVerifyWithHDLCosimulation=true;
            end
        else
            hWC.RunTaskVerifyWithHDLCosimulation=false;
        end

        hWC.IPAddress=hDI.hFilBuildInfo.IPAddress;
        hWC.MACAddress=hDI.hFilBuildInfo.MACAddress;
        hWC.SourceFiles='';
        for i=1:numel(hDI.hFilBuildInfo.SourceFiles.FilePath)
            hWC.SourceFiles=[hWC.SourceFiles,hDI.hFilBuildInfo.SourceFiles.FilePath{i},';',hDI.hFilBuildInfo.SourceFiles.FileType{i},';'];
        end
        hManager=eda.internal.boardmanager.BoardManager.getInstance;
        ConnectionsAvailable=hManager.getBoardObj(hDI.hFilBuildInfo.Board).getFILConnectionOptions;
        connectionIndex=min(hDI.hFilWizardDlg.ConnectionSelection+1,numel(ConnectionsAvailable));
        hWC.Connection=ConnectionsAvailable{connectionIndex}.Name;
        hWC.EnableDataBufferingOnFPGA=hDI.hFilBuildInfo.EnableHWBuffer;

        hWC.RunExternalBuild=true;

        if~strcmpi(ConnectionsAvailable{connectionIndex}.RTIOStreamLibName,'mwrtiostreamtcpip')
            filProperties=hWC.Properties('RunTaskBuildFPGAInTheLoop');
            filProperties(ismember(filProperties,{'IPAddress','MACAddress','EnableDataBufferingOnFPGA'}))=[];
            hWC.Properties('RunTaskBuildFPGAInTheLoop')=filProperties;
        end
    end


    hdlwa.hdlwa_exportToScript(hWC);
end


