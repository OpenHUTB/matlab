function ValidateModel(obj)

    sys=obj.sys;
    prjDir=obj.ProjectDir;
    if~bdIsLoaded(sys)
        load_system(sys);
    end
    vendor=soc.internal.getVendor(sys);
    warningProgressText='';
    try
        if obj.HasFPGA

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
        end

        if obj.HasFPGA

            if obj.HasReferenceDesign

                supportedVersion=obj.ReferenceDesignInfo.SupportedToolVersion{1};
                soc.internal.validateToolVersion(vendor,supportedVersion);
            else
                soc.internal.validateToolVersion(vendor);
            end

            if~isempty(dut)&&~dig.isProductInstalled('HDL Coder')
                error(message('soc:msgs:NoHDLCoderLicense'));
            end
        end

        if obj.HasESW&&~obj.Debug
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


        if obj.isModelProcessorOnly(obj.sys)
            [status,statusMsg]=l_validateModelForMultiCPU(obj);
            if isequal(status,'error')
                error(statusMsg);
            end
        end

        feature('ResetLastPrintedWarning');
        set_param(sys,'SimulationCommand','update');

        lastDispWarn=warning('query','last');
        if~isempty(lastDispWarn)
            warningProgressText=[message('soc:workflow:ValidateModel_CompilationWarn',sys).getString(),'<br/>&nbsp;'];
        end


        if obj.HasEventDrivenTasks
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
        end

        if obj.SupportsPeripherals
            hwBoardName=regexprep(get_param(obj.sys,'HardwareBoard'),'\s+','');
            if exist(sprintf('codertarget.peripherals.%s',hwBoardName),'class')
                codertarget.peripherals.(hwBoardName).validatePeripheralConfig(obj.sys,obj.ExtModelInfo);
            end
        end
        if obj.HasFPGA

            [status,statusMsg,memMap]=soc.memmap.getMapForWorkflow(sys);
            switch status
            case 'info'
                disp(statusMsg.getString());
            case 'warning'
                warningProgressText=[warningProgressText,statusMsg.getString(),'<br/>&nbsp;'];
            case 'error'
                error(statusMsg);
            end
        end
        if~obj.HasReferenceDesign
            if obj.HasFPGA

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
                end
                obj.hbuild=hbuild;
                obj.socsysinfo=socsysinfo;
            end

            if obj.BoardSupportsMultipleConfigurations
                soc.internal.boardconfiguration.checkAllConsistent(sys);
            end


            codeGenFolder=Simulink.fileGenControl('get','CodeGenFolder');
            if strcmpi(obj.ModelType,obj.SocFpga)
                socsysinfo.modelinfo.arm_model=obj.ProcessorModel;
                socsysinfo.projectinfo.sw_system=[sys,'_sw'];
                if obj.BuildAction~=obj.OpenExternalModeModel
                    socsysinfo.projectinfo.elf_file=fullfile(codeGenFolder,[sys,'_sw.elf']);
                end
            end


            if strcmpi(obj.ModelType,obj.ProcessorOnly)
                socsysinfo.projectinfo.prj_dir=prjDir;
                socsysinfo.projectinfo.board=soc.internal.getBoardID(obj.HardwareBoard);
                socsysinfo.projectinfo.fullboardname=obj.HardwareBoard;
                socsysinfo.projectinfo.vendor=vendor;
                socsysinfo.modelinfo.sys=sys;
                socsysinfo.modelinfo.arm_model=obj.ProcessorModel;
                socsysinfo.projectinfo.report=fullfile(prjDir,'html',[sys,'_system_report.html']);

                if(obj.BuildAction~=obj.OpenExternalModeModel)
                    exe_ext=codertarget.tools.getApplicationExtension(getActiveConfigSet(sys));
                    if~obj.isModelMultiCPU(sys)
                        socsysinfo.projectinfo.elf_file=fullfile(codeGenFolder,[sys,'_sw',exe_ext]);
                    else
                        if~iscell(obj.SysDeployer.SoftwareSystemModel)
                            socsysinfo.projectinfo.elf_file=fullfile(codeGenFolder,[obj.SysDeployer.SoftwareSystemModel,exe_ext]);
                        else
                            for i=1:numel(obj.SysDeployer.SoftwareSystemModel)
                                socsysinfo.projectinfo.elf_file{i}=fullfile(codeGenFolder,[obj.SysDeployer.SoftwareSystemModel{i},exe_ext]);
                            end
                        end
                    end
                end



                if obj.isModelProcessorOnly(obj.sys)
                    socsysinfo.projectinfo.ExtModelInfo=obj.ExtModelInfo;
                end
            end

            soc.genReport(socsysinfo,0);


            socsysinfo.projectinfo.build_action=obj.BuildAction;
            if~isfolder(prjDir)
                mkdir(prjDir);
            end
            save(fullfile(prjDir,'socsysinfo.mat'),'socsysinfo');

            obj.socsysinfo=socsysinfo;

            if obj.HasESW||obj.isModelProcessorOnly(obj.sys)
                loadProjectInfo(obj.SysDeployer,obj.ProjectDir);
            end

        else
            if numel(dut)>1
                error(message('soc:msgs:checkNumDUTs'));
            end

            obj.hbuild.DUTName=soc.util.getDUT(fpgaModel);

            [regInPorts,regOutPorts,~,~,regChPortMap]=soc.internal.getDUTRegPorts(obj.hbuild.DUTName{1},sys);
            allDUTPorts=[regInPorts,regOutPorts,regChPortMap.keys];
            obj.hbuild.IntfInfo=containers.Map;
            soc.internal.validateReferenceDesignWF(fpgaModel,dut,regChPortMap);
            if obj.HasESW
                topInfo=soc.getTopInfo(sys,memMap,dut,obj.HasReferenceDesign);
                intfInfo=soc.getIOInterface(fpgaModel,dut,topInfo);
                hbuild=soc.BuildInfo(fpgaModel,sys,dut,...
                prjDir,'TopInfo',topInfo,'Verbose',false,...
                'NumJobs',min(feature('numthreads'),20),'IntfInfo',intfInfo,'MemMap',memMap,'HasReferenceDesign',true);
                socsysinfo=soc.getHandoffInfo(hbuild);

                codeGenFolder=Simulink.fileGenControl('get','CodeGenFolder');
                socsysinfo.modelinfo.arm_model=obj.ProcessorModel;
                socsysinfo.projectinfo.sw_system=[sys,'_sw'];
                if obj.BuildAction~=obj.OpenExternalModeModel
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
                socsysinfo.ipcoreinfo.mwipcore_info.blk_name=obj.hbuild.DUTName{1};
                socsysinfo.projectinfo.vendor=vendor;
            end
            socsysinfo.projectinfo.bit_file=fullfile(obj.ProjectDir,'vivado_ip_prj','vivado_prj.runs','impl_1','system_wrapper.bit');
            for ii=1:numel(allDUTPorts)
                l_port=allDUTPorts{ii};

                if isKey(regChPortMap,l_port)
                    regName=regChPortMap(l_port);
                else
                    regName=get_param(l_port,'name');
                end
                regOffset=soc.memmap.getRegOffset(memMap,get_param(obj.hbuild.DUTName{1},'name'),regName);

                regOffset=['x"',regOffset(3:end),'"'];
                obj.hbuild.IntfInfo(l_port)=...
                struct('interface',obj.ReferenceDesignInfo.RegisterInterface,...
                'interfacePort',regOffset);
            end

            socsysinfo.modelinfo.hasReferenceDesign=true;
            socsysinfo.projectinfo.build_action=obj.BuildAction;
            if~isfolder(prjDir)
                mkdir(prjDir);
            end
            obj.socsysinfo=socsysinfo;
            save(fullfile(prjDir,'socsysinfo.mat'),'socsysinfo');
            if obj.HasESW
                loadProjectInfo(obj.SysDeployer,obj.ProjectDir);
            end
        end


    catch ME
        if obj.Debug
            rethrow(ME);
        end
    end
end


function[status,statusMsg]=l_validateModelForMultiCPU(obj)
    status='info';
    statusMsg='';

    NumberOfCPUs=codertarget.utils.internal.getNumOfProcessingUnit(obj.sys);
    if NumberOfCPUs>1
        if~iscell(obj.ProcessorModel)
            procMdls={obj.ProcessorModel};
        else
            procMdls=obj.ProcessorModel;
        end

        if numel(procMdls)>NumberOfCPUs

            status='error';
            statusMsg=message('soc:workflow:TaskMgrBlocksMoreThanNumOfCPUs',obj.sys).getString();
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


    if codertarget.utils.isHeterogenousProcessorBoard(obj.sys)
        folderStructure=Simulink.fileGenControl('get','CodeGenFolderStructure');
        if~isequal(folderStructure,Simulink.filegen.CodeGenFolderStructure.TargetEnvironmentSubfolder)
            status='error';
            statusMsg=message('soc:workflow:UnsupportedFolderStructure').getString();
        end
    end


    if obj.BuildAction==obj.OpenExternalModeModel
        hwBoardName=regexprep(get_param(obj.sys,'HardwareBoard'),'\s+','');
        if exist(sprintf('codertarget.peripherals.%s',hwBoardName),'class')
            codertarget.peripherals.(hwBoardName).validateCOMPort(obj.ExtModelInfo);
        end
    end
end



