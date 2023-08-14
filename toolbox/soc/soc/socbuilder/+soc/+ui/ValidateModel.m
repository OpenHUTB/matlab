classdef ValidateModel<soc.ui.TemplateWithValidation





    methods
        function this=ValidateModel(varargin)
            this@soc.ui.TemplateWithValidation(varargin{:});


            this.setCurrentStep(2);
            this.Title.Text=message('soc:workflow:ValidateModel_Title').getString();

            this.Description.Text='';

            this.StatusTable.Steps=getListOfChecks(this);
            this.clearStatusTable();

            this.ValidationResult.Steps={message('soc:workflow:ValidateModel_Description').getString()};

            this.ValidationAction.Text='Validate';
            this.ValidationAction.ButtonPushedFcn=@this.startValidationCB;

            this.HelpText.WhatToConsider='';
            this.HelpText.AboutSelection='';
            this.HelpText.Additional='';
        end

        function screen=getNextScreenID(this)
            if this.Workflow.BuildAction==this.Workflow.OpenExternalModeModel
                if~this.Workflow.isModelProcessorOnly(this.Workflow.sys)&&strcmpi(this.Workflow.ModelType,this.Workflow.ProcessorOnly)
                    screen='soc.ui.ConnectHardware';
                else



                    screen='soc.ui.BuildModel';
                end
            else
                screen='soc.ui.BuildModel';
            end
        end
        function screen=getPreviousScreenID(this)
            if~isempty(this.Workflow.BuildAction)&&...
                (this.Workflow.BuildAction==this.Workflow.OpenExternalModeModel)&&...
                this.Workflow.isModelMultiCPU(this.Workflow.sys)
                screen='soc.ui.ExternalModeConnectivity';
            else
                screen='soc.ui.SelectBuildAction';
            end
        end

        function validateTestCB(this,~,~)
            this.startValidationCB;
        end
    end

    methods(Access=private)
        function steps=getListOfChecks(this)
            steps={};
            if this.Workflow.HasFPGA
                steps{end+1}=message('soc:workflow:ValidateModel_Check_FPGAModel').getString();
            end
            steps{end+1}=message('soc:workflow:ValidateModel_Check_RequiredProductAndVendorTool').getString();
            steps{end+1}=message('soc:workflow:ValidateModel_Check_ModelCompilation').getString();
            if this.Workflow.HasEventDrivenTasks
                steps{end+1}=message('soc:workflow:ValidateModel_Check_TaskMap').getString();
            end
            if this.Workflow.SupportsPeripherals
                steps{end+1}=message('soc:workflow:ValidateModel_Check_PeripheralConfig').getString();
            end
            if this.Workflow.HasFPGA
                steps{end+1}=message('soc:workflow:ValidateModel_Check_MemMap').getString();
                steps{end+1}=message('soc:workflow:ValidateModel_Check_ParseBuildInfo').getString();
            end
            if this.Workflow.BoardSupportsMultipleConfigurations
                steps{end+1}=message('soc:workflow:ValidateModel_Check_BoardConfig').getString();
            end
        end

        function CleanupFun(this)
            if isprop(this,'Workflow')&&(this.Workflow.isvalid)
                busyStatusIcon=matlab.hwmgr.internal.hwsetup.StatusIcon(5);
                if strcmp(busyStatusIcon.dispIcon(),this.ValidationResult.Status{1})
                    this.BackButton.Enable='on';
                    this.CancelButton.Enable='on';
                    this.clearStatusTable();
                    this.ValidationResult.Steps={message('soc:workflow:ValidateModel_Description').getString()};
                    this.ValidationResult.Status={''};
                    this.ValidationAction.Enable='on';
                end
            end
        end

        function startValidationCB(this,~,~)
            sys=this.Workflow.sys;
            prjDir=this.Workflow.ProjectDir;
            if~bdIsLoaded(sys)
                load_system(sys);
            end
            vendor=soc.internal.getVendor(sys);
            this.clearStatusTable();
            cleanup=onCleanup(@()this.CleanupFun);
            this.setValidationStatus('busy',message('soc:workflow:ValidateModel_Status_Busy').getString);
            this.NextButton.Enable='off';
            this.BackButton.Enable='off';
            this.CancelButton.Enable='off';
            this.HelpText.Additional='';

            step=1;
            warningProgressText='';
            try
                if this.Workflow.HasFPGA
                    this.setBusy(step);

                    soc.internal.validateCompatibleBoard(sys);
                    [~,fpgaModel]=soc.util.getHSBSubsystem(sys);
                    if~isempty(fpgaModel)
                        load_system(fpgaModel);
                        dut=soc.util.getDUT(fpgaModel);
                        if isempty(dut)
                            error(message('soc:msgs:checkFpgaNoDUTFound',fpgaModel));
                        else
                            dut=get_param(dut,'Name');
                        end
                    else
                        dut='';
                    end
                    this.setSuccess(step);
                    step=step+1;
                end

                this.setBusy(step);

                if this.Workflow.HasFPGA

                    if this.Workflow.HasReferenceDesign

                        supportedVersion=this.Workflow.ReferenceDesignInfo.SupportedToolVersion{1};
                        soc.internal.validateToolVersion(vendor,supportedVersion);
                    else
                        soc.internal.validateToolVersion(vendor);
                    end

                    if~isempty(dut)&&~dig.isProductInstalled('HDL Coder')
                        error(message('soc:msgs:NoHDLCoderLicense'));
                    end
                end

                if this.Workflow.HasESW&&~this.Workflow.Debug
                    if~dig.isProductInstalled('Simulink Coder')
                        error(message('soc:msgs:NoSimulinkCoderLicense'));
                    end
                    if~dig.isProductInstalled('Embedded Coder')
                        error(message('soc:msgs:NoEmbeddedCoderLicense'));
                    end
                    taskMgrBlks=soc.internal.connectivity.getTaskManagerBlock(sys);
                    if~iscell(taskMgrBlks)
                        taskMgrBlks={taskMgrBlks};
                    end
                    for taskMgrBlkIdx=1:numel(taskMgrBlks)
                        mgrBlk=taskMgrBlks{taskMgrBlkIdx};
                        refMdl=soc.internal.connectivity.getModelConnectedToTaskManager(mgrBlk);
                        refMdlName=get_param(refMdl,'ModelName');
                        if~bdIsLoaded(refMdlName)
                            load_system(refMdlName);
                        end
                        if soc.internal.taskmanager.hasEventDrivenTasks(mgrBlk)&&...
                            isequal(get_param(refMdlName,'ModelReferenceNumInstancesAllowed'),'Multi')
                            error(message('soc:msgs:NumRefMdlInstancesInvalid',refMdlName))
                        end
                        soc.internal.crosscheckBoardAndBlocks(refMdlName);
                    end
                end
                this.setSuccess(step);
                step=step+1;


                this.setBusy(step);


                if this.Workflow.isModelProcessorOnly(this.Workflow.sys)
                    [status,statusMsg]=validateModelForMultiCPU(this);
                    if isequal(status,'error')
                        error(statusMsg);
                    end
                end

                feature('ResetLastPrintedWarning');
                set_param(sys,'SimulationCommand','update');

                lastDispWarn=warning('query','last');
                if isempty(lastDispWarn)
                    this.setSuccess(step);
                else
                    this.setWarn(step);
                    warningProgressText=[message('soc:workflow:ValidateModel_CompilationWarn',sys).getString(),'<br/>&nbsp;'];
                end
                step=step+1;


                if this.Workflow.HasEventDrivenTasks
                    this.setBusy(step);
                    taskMgrBlk=soc.internal.connectivity.getTaskManagerBlock(sys);
                    if~iscell(taskMgrBlk)
                        taskMgrBlk={taskMgrBlk};
                    end
                    for taskMgrBlkIdx=1:numel(taskMgrBlk)
                        if codertarget.targethardware.isAutoMappingSupported(getActiveConfigSet(sys))
                            soc.internal.taskmanager.autoassignTaskToEventSource(taskMgrBlk{taskMgrBlkIdx});
                        end
                        soc.internal.taskmanager.verifyTaskToEventSourceAssignment(taskMgrBlk{taskMgrBlkIdx})
                    end
                    this.setSuccess(step);
                    step=step+1;
                end

                if this.Workflow.SupportsPeripherals
                    this.setBusy(step);
                    hwBoardName=regexprep(get_param(this.Workflow.sys,'HardwareBoard'),'\s+','');
                    if exist(sprintf('codertarget.peripherals.%s',hwBoardName),'class')
                        codertarget.peripherals.(hwBoardName).validatePeripheralConfig(this.Workflow.sys,this.Workflow.ExtModelInfo);
                    end
                    this.setSuccess(step);
                    step=step+1;
                end
                if this.Workflow.HasFPGA

                    this.setBusy(step);
                    [status,statusMsg,memMap]=soc.memmap.getMapForWorkflow(sys);
                    switch status
                    case 'info'
                        disp(statusMsg.getString());
                        this.setSuccess(step);
                    case 'warning'
                        warningProgressText=[warningProgressText,statusMsg.getString(),'<br/>&nbsp;'];
                        this.setWarn(step);
                    case 'error'
                        error(statusMsg);
                    end

                    step=step+1;
                end
                if~this.Workflow.HasReferenceDesign
                    if this.Workflow.HasFPGA

                        this.setBusy(step);
                        topInfo=soc.getTopInfo(sys,memMap,dut);
                        intfInfo=soc.getIOInterface(fpgaModel,dut,topInfo);
                        hbuild=soc.BuildInfo(fpgaModel,sys,dut,...
                        prjDir,'TopInfo',topInfo,'Verbose',false,...
                        'NumJobs',min(feature('numthreads'),20),'IntfInfo',intfInfo,'MemMap',memMap);
                        socsysinfo=soc.getHandoffInfo(hbuild);
                        AXIMasterInfo=soc.genIPCoreRegInfo(socsysinfo,topInfo);
                        soc.genJTAGScript(AXIMasterInfo,hbuild,socsysinfo,0);
                        checkStatus=soc.checkFPGADesign(hbuild,socsysinfo,topInfo);
                        soc.genCheckReport(checkStatus,socsysinfo,prjDir);
                        checkreport_name=[sys,'_validation_report.html'];
                        checkreport_location=fullfile(prjDir,'html',checkreport_name);
                        if any([checkStatus.Status]==1)
                            error(message('soc:msgs:checkFpgaError',checkreport_location));
                        end

                        if any([checkStatus.Status]==2)
                            warningProgressText=[warningProgressText...
                            ,message('soc:msgs:checkFpgaWarning',checkreport_location).getString()];
                            this.setWarn(step);
                        else
                            this.setSuccess(step);
                        end
                        this.Workflow.hbuild=hbuild;
                        this.Workflow.socsysinfo=socsysinfo;
                        step=step+1;
                    end

                    if this.Workflow.BoardSupportsMultipleConfigurations
                        this.setBusy(step);
                        soc.internal.boardconfiguration.checkAllConsistent(sys);
                        this.setSuccess(step);
                        step=step+1;
                    end


                    codeGenFolder=Simulink.fileGenControl('get','CodeGenFolder');
                    if strcmpi(this.Workflow.ModelType,this.Workflow.SocFpga)
                        socsysinfo.modelinfo.arm_model=this.Workflow.ProcessorModel;
                        socsysinfo.projectinfo.sw_system=[sys,'_sw'];
                        if this.Workflow.BuildAction~=this.Workflow.OpenExternalModeModel
                            socsysinfo.projectinfo.elf_file=fullfile(codeGenFolder,[sys,'_sw.elf']);
                        end
                    end


                    if strcmpi(this.Workflow.ModelType,this.Workflow.ProcessorOnly)
                        socsysinfo.projectinfo.prj_dir=prjDir;
                        socsysinfo.projectinfo.board=soc.internal.getBoardID(this.Workflow.HardwareBoard);
                        socsysinfo.projectinfo.fullboardname=this.Workflow.HardwareBoard;
                        socsysinfo.projectinfo.vendor=vendor;
                        socsysinfo.modelinfo.sys=sys;
                        socsysinfo.modelinfo.arm_model=this.Workflow.ProcessorModel;
                        socsysinfo.projectinfo.report=fullfile(prjDir,'html',[sys,'_system_report.html']);

                        if(this.Workflow.BuildAction~=this.Workflow.OpenExternalModeModel)
                            exe_ext=codertarget.tools.getApplicationExtension(getActiveConfigSet(sys));
                            if~this.Workflow.isModelMultiCPU(sys)
                                socsysinfo.projectinfo.elf_file=fullfile(codeGenFolder,[sys,'_sw',exe_ext]);
                            else
                                if~iscell(this.Workflow.SysDeployer.SoftwareSystemModel)
                                    socsysinfo.projectinfo.elf_file=fullfile(codeGenFolder,[this.Workflow.SysDeployer.SoftwareSystemModel,exe_ext]);
                                else
                                    for i=1:numel(this.Workflow.SysDeployer.SoftwareSystemModel)
                                        socsysinfo.projectinfo.elf_file{i}=fullfile(codeGenFolder,[this.Workflow.SysDeployer.SoftwareSystemModel{i},exe_ext]);
                                    end
                                end
                            end
                        end



                        if this.Workflow.isModelProcessorOnly(this.Workflow.sys)
                            socsysinfo.projectinfo.ExtModelInfo=this.Workflow.ExtModelInfo;
                        end
                    end

                    soc.genReport(socsysinfo,0);


                    socsysinfo.projectinfo.build_action=this.Workflow.BuildAction;
                    if~isfolder(prjDir)
                        mkdir(prjDir);
                    end
                    save(fullfile(prjDir,'socsysinfo.mat'),'socsysinfo');

                    this.Workflow.socsysinfo=socsysinfo;

                    if this.Workflow.HasESW||this.Workflow.isModelProcessorOnly(this.Workflow.sys)
                        loadProjectInfo(this.Workflow.SysDeployer,this.Workflow.ProjectDir);
                    end

                    this.HelpText.Additional=message('soc:workflow:ValidateModel_Additional',socsysinfo.projectinfo.report).getString();
                else
                    this.setBusy(step);
                    if numel(dut)>1
                        error(message('soc:msgs:checkNumDUTs'));
                    end

                    this.Workflow.hbuild.DUTName=soc.util.getDUT(fpgaModel);

                    [regInPorts,regOutPorts,~,~,regChPortMap]=soc.internal.getDUTRegPorts(this.Workflow.hbuild.DUTName{1},sys);
                    allDUTPorts=[regInPorts,regOutPorts,regChPortMap.keys];
                    this.Workflow.hbuild.IntfInfo=containers.Map;
                    soc.internal.validateReferenceDesignWF(fpgaModel,dut,regChPortMap);
                    if this.Workflow.HasESW
                        topInfo=soc.getTopInfo(sys,memMap,dut,this.Workflow.HasReferenceDesign);
                        intfInfo=soc.getIOInterface(fpgaModel,dut,topInfo);
                        hbuild=soc.BuildInfo(fpgaModel,sys,dut,...
                        prjDir,'TopInfo',topInfo,'Verbose',false,...
                        'NumJobs',min(feature('numthreads'),20),'IntfInfo',intfInfo,'MemMap',memMap,'HasReferenceDesign',true);
                        socsysinfo=soc.getHandoffInfo(hbuild);

                        codeGenFolder=Simulink.fileGenControl('get','CodeGenFolder');
                        socsysinfo.modelinfo.arm_model=this.Workflow.ProcessorModel;
                        socsysinfo.projectinfo.sw_system=[sys,'_sw'];
                        if this.Workflow.BuildAction~=this.Workflow.OpenExternalModeModel
                            socsysinfo.projectinfo.elf_file=fullfile(codeGenFolder,[sys,'_sw.elf']);
                        end
                        socsysinfo.ipcoreinfo.mwipcore_info.ipcore_name='ipcore';
                        keys=socsysinfo.modelinfo.map_axi2dut.keys;
                        for i=1:numel(keys)
                            temp=socsysinfo.modelinfo.map_axi2dut(keys{i});
                            temp.ipcore_name='ipcore';
                            socsysinfo.modelinfo.map_axi2dut(keys{i})=temp;
                        end
                    else
                        socsysinfo.modelinfo.sys=sys;
                        socsysinfo.ipcoreinfo.mwipcore_info.blk_name=this.Workflow.hbuild.DUTName{1};
                        socsysinfo.projectinfo.vendor=vendor;
                    end
                    socsysinfo.projectinfo.bit_file=fullfile(this.Workflow.ProjectDir,'vivado_ip_prj','vivado_prj.runs','impl_1','system_wrapper.bit');
                    for ii=1:numel(allDUTPorts)
                        thisPort=allDUTPorts{ii};

                        if isKey(regChPortMap,thisPort)
                            regName=regChPortMap(thisPort);
                        else
                            regName=get_param(thisPort,'name');
                        end
                        regOffset=soc.memmap.getRegOffset(memMap,get_param(this.Workflow.hbuild.DUTName{1},'name'),regName);

                        regOffset=['x"',regOffset(3:end),'"'];
                        this.Workflow.hbuild.IntfInfo(thisPort)=...
                        struct('interface',this.Workflow.ReferenceDesignInfo.RegisterInterface,...
                        'interfacePort',regOffset);
                    end

                    socsysinfo.modelinfo.hasReferenceDesign=true;
                    socsysinfo.projectinfo.build_action=this.Workflow.BuildAction;
                    if~isfolder(prjDir)
                        mkdir(prjDir);
                    end
                    this.Workflow.socsysinfo=socsysinfo;
                    save(fullfile(prjDir,'socsysinfo.mat'),'socsysinfo');
                    if this.Workflow.HasESW
                        loadProjectInfo(this.Workflow.SysDeployer,this.Workflow.ProjectDir);
                    end
                    this.setSuccess(step);
                end

                this.NextButton.Enable='on';
                this.BackButton.Enable='on';
                this.CancelButton.Enable='on';

                if~isempty(warningProgressText)
                    this.setValidationStatus('warn',warningProgressText);
                else
                    this.setValidationStatus('pass',message('soc:workflow:ValidateModel_Status_Pass').getString);
                end

            catch ME
                this.BackButton.Enable='on';
                this.CancelButton.Enable='on';
                this.setFailure(step);
                if~isempty(ME.cause)
                    msg=ME.cause{1}.message;
                else
                    msg=ME.message;
                end
                this.setValidationStatus('fail',msg);
                if this.Workflow.Debug
                    rethrow(ME);
                end
            end
        end
    end

    methods(Access=private)
        function[status,statusMsg]=validateModelForMultiCPU(this)
            status='info';
            statusMsg='';

            NumberOfCPUs=codertarget.utils.internal.getNumOfProcessingUnit(this.Workflow.sys);
            if NumberOfCPUs>1
                if~iscell(this.Workflow.ProcessorModel)
                    procMdls={this.Workflow.ProcessorModel};
                else
                    procMdls=this.Workflow.ProcessorModel;
                end

                if numel(procMdls)>NumberOfCPUs

                    status='error';
                    statusMsg=message('soc:workflow:TaskMgrBlocksMoreThanNumOfCPUs',this.Workflow.sys).getString();
                else

                    selectedCPUs=cellfun(@(x)codertarget.targethardware.getProcessingUnitName(x),procMdls,'UniformOutput',false);


                    areAnyProcUnitsNone=strcmp(selectedCPUs,'None');
                    if any(areAnyProcUnitsNone)
                        status='error';
                        statusMsg=message('soc:workflow:ProcModelProcessingUnitNone').getString;
                    else

                        uniqueSelectedCPUs=unique(selectedCPUs);
                        if~isequal(numel(uniqueSelectedCPUs),numel(selectedCPUs))
                            status='error';
                            statusMsg=message('soc:workflow:NonUniqueProdMdlCPU').getString();
                        end
                    end
                end
            end


            if codertarget.utils.isHeterogenousProcessorBoard(this.Workflow.sys)
                folderStructure=Simulink.fileGenControl('get','CodeGenFolderStructure');
                if~isequal(folderStructure,Simulink.filegen.CodeGenFolderStructure.TargetEnvironmentSubfolder)
                    status='error';
                    statusMsg=message('soc:workflow:UnsupportedFolderStructure').getString();
                end
            end


            if this.Workflow.BuildAction==this.Workflow.OpenExternalModeModel
                hwBoardName=regexprep(get_param(this.Workflow.sys,'HardwareBoard'),'\s+','');
                if exist(sprintf('codertarget.peripherals.%s',hwBoardName),'class')
                    codertarget.peripherals.(hwBoardName).validateCOMPort(this.Workflow.ExtModelInfo);
                end
            end
        end
    end
end


