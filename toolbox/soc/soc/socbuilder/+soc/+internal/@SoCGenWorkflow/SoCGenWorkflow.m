classdef SoCGenWorkflow<handle





    properties

Name

ProjectDir
sys
FPGAModel
ProcessorModel
hbuild
socsysinfo
BuildAction
ModelType
        LoadExisting=false

dutName
exportDirectory
exportBoardDir
boardName
designName
ExportRD
        HasEventDrivenTasks=false


SupportsPeripherals
BoardSupportsMultipleConfigurations
        HasReferenceDesign=false
ReferenceDesignInfo
    end

    properties(Constant,Hidden)
        EnableBitGenPrefName='EnableBitGen';
        EnablePrjGenPrefName='EnablePrjGen';
        ProcessorOnly='arm';
        SocFpga='soc';
        FpgaOnly='fpga';
        BuildOnly=1;
        BuildAndLoad=2;
        OpenExternalModeModel=3;
    end

    properties(Hidden,Dependent)
HardwareBoard
SWModel
EnableBitGen
EnablePrjGen
HasESW
HasFPGA
GenHDLModel
HasHDMI
    end

    properties(Hidden)
SysDeployer
HWInterfaceObj
ESWElf

        Debug=false
        ADIHDLDir=''
        ExternalBuild=true
        EnableSWMdlGen=true
ExtModelInfo
    end

    methods
        function obj=SoCGenWorkflow(varargin)

            if~builtin('license','checkout','SoC_Blockset')
                error(message('soc:utils:NoLicense'));
            end


            try
                narginchk(1,1);
                sys=varargin{1};
            catch
                error(message('soc:workflow:Launch_InvalidInput'));
            end


            soc.internal.validateModelName(sys);
            if isstring(sys)
                sys=char(sys);
            end
            if~bdIsLoaded(sys)
                load_system(sys);
            end


            soc.internal.validateCompatibleBoard(sys);


            processorModel=soc.internal.SoCGenWorkflow.getESWRefModel(sys);


            if obj.isModelProcessorOnly(sys)
                fpgaModelBlock=[];
                fpgaModel=[];
            else
                [fpgaModelBlock,fpgaModel]=soc.util.getHSBSubsystem(sys);
                if isempty(fpgaModel)&&soc.internal.hasATG(sys)
                    fpgaModel=sys;
                end
            end

            if~isempty(fpgaModel)&&isempty(processorModel)
                modelType=obj.FpgaOnly;
            elseif isempty(fpgaModel)&&~isempty(processorModel)
                modelType=obj.ProcessorOnly;
            elseif~isempty(fpgaModel)&&~isempty(processorModel)
                modelType=obj.SocFpga;
            else
                error(message('soc:msgs:NothingToGen'));
            end

            hasProcessor=soc.internal.hasProcessor(sys);
            if~strcmp(modelType,obj.FpgaOnly)
                if~hasProcessor
                    error(message('soc:msgs:ProcessorModelWithPSOff'));
                end
            end


            if~isempty(processorModel)
                if~iscell(processorModel)
                    if~bdIsLoaded(processorModel)
                        load_system(processorModel);
                    end
                    assert(isequal(get_param(sys,'HardwareBoard'),get_param(processorModel,'HardwareBoard')),message('soc:msgs:BoardNameMismatch'));
                else
                    for i=1:numel(processorModel)
                        if~bdIsLoaded(processorModel{i})
                            load_system(processorModel{i});
                        end
                        assert(isequal(get_param(sys,'HardwareBoard'),get_param(processorModel{i},'HardwareBoard')),message('soc:msgs:BoardNameMismatch'));
                    end
                end
            end

            if~isempty(fpgaModelBlock)
                soc.internal.validateFPGAModelBlock(fpgaModelBlock);
            end

            if soc.internal.SoCGenWorkflow.isModelProcessorOnly(sys)
                ExtMdlInfo=struct('CPU','',...
                'EnableExtMode',false,...
                'TopModel','',...
                'RefModel','',...
                'Interface','',...
                'Connectivity','',...
                'Connectivity1','',...
                'Verbose',0);
                if~iscell(processorModel)
                    CPUWithProcModels={codertarget.targethardware.getProcessingUnitName(processorModel)};
                else
                    CPUWithProcModels=cellfun(@(x)codertarget.targethardware.getProcessingUnitName(x),processorModel,'UniformOutput',false);
                end
                obj.ExtModelInfo=containers.Map;
                for i=1:numel(CPUWithProcModels)
                    if~iscell(processorModel)
                        RefMdls=processorModel;
                    else
                        RefMdls=processorModel(i);
                        if iscell(RefMdls)
                            RefMdls=RefMdls{1};
                        end
                    end
                    ExtMdlInfoNew=ExtMdlInfo;
                    ExtMdlInfoNew.CPU=CPUWithProcModels{i};
                    ExtMdlInfoNew.EnableExtMode=false;
                    ExtMdlInfoNew.TopModel='';
                    ExtMdlInfoNew.RefModel=RefMdls;
                    ExtMdlInfoNew.Interface='';
                    ExtMdlInfoNew.Connectivity='';
                    ExtMdlInfoNew.Connectivity1=[];
                    ExtMdlInfoNew.Verbose=false;

                    obj.ExtModelInfo(ExtMdlInfoNew.CPU)=ExtMdlInfoNew;
                end
            end

            obj.sys=sys;
            obj.FPGAModel=fpgaModel;
            obj.ProcessorModel=processorModel;
            obj.ModelType=modelType;
            obj.boardName=get_param(sys,'HardwareBoard');


            tskMgrBlks=soc.internal.connectivity.getTaskManagerBlock(...
            obj.sys,'overrideAssert');
            if~isempty(tskMgrBlks)
                if~iscell(tskMgrBlks),tskMgrBlks={tskMgrBlks};end
                obj.HasEventDrivenTasks=...
                any(cellfun(@(x)soc.internal.taskmanager.hasEventDrivenTasks(x),tskMgrBlks));
            end


            if~obj.isRequiredSupportPackageInstalled()
                return;
            end




            defFile=codertarget.peripherals.utils.getDefFileNameForBoard(sys);
            appModel=codertarget.peripherals.AppModel(sys,defFile);
            obj.SupportsPeripherals=~isempty(appModel.SupportedPeripheralInfo)&&...
            appModel.arePeripheralBlocksInRefModels();

            [obj.HasReferenceDesign,obj.ReferenceDesignInfo]=soc.internal.getReferenceDesignInfo(fpgaModel);

            if hasProcessor||...
                (obj.HasReferenceDesign&&obj.ReferenceDesignInfo.HasProcessingSystem)
                obj.SysDeployer=soc.SystemDeployer(sys,'ConnectHardware',false);
                if~obj.isModelProcessorOnly(obj.sys)
                    obj.HWInterfaceObj=soc.internal.oscustomization.HWInterface.getInstance();
                end
            end
            obj.BoardSupportsMultipleConfigurations=...
            codertarget.targethardware.hasBoardConfiguration(sys);
        end
    end

    methods
        ValidateModel(obj);
    end

    methods
        function ret=get.HardwareBoard(obj)
            ret=get_param(obj.sys,'HardwareBoard');
        end

        function ret=get.SWModel(obj)
            ret=obj.SysDeployer.SoftwareSystemModel;
        end
        function ret=get.GenHDLModel(obj)
            ret=['gm_',obj.FPGAModel];
        end

        function ret=get.HasESW(obj)
            if isequal(obj.ModelType,obj.ProcessorOnly)||isequal(obj.ModelType,obj.SocFpga)
                ret=true;
            else
                ret=false;
            end
        end

        function ret=get.HasFPGA(obj)
            if isequal(obj.ModelType,obj.FpgaOnly)||isequal(obj.ModelType,obj.SocFpga)
                ret=true;
            else
                ret=false;
            end
        end

        function ret=get.HasHDMI(obj)
            fmcIOBlks=obj.getFMCIOBlocks(obj.sys,obj.FPGAModel);
            ret=false;
            for i=1:length(fmcIOBlks)
                libRefBlk=libinfo(fmcIOBlks{i},'searchdepth',0);
                if strcmp(libRefBlk.ReferenceBlock,'xilinxsocvisionlib/HDMI Rx')
                    ret=true;
                    break;
                else
                    ret=false;
                end
            end
        end

        function ret=get.EnablePrjGen(obj)
            ret=obj.getWorkflowPref(obj.EnablePrjGenPrefName,true);
        end

        function ret=get.EnableBitGen(obj)
            if~obj.EnablePrjGen
                ret=false;
            else
                ret=obj.getWorkflowPref(obj.EnableBitGenPrefName,true);
            end
        end
    end

    methods(Hidden)
        function out=isRequiredSupportPackageInstalled(obj)
            out=true;
            if soc.internal.hasProcessor(obj.sys)||soc.internal.hasJTAGMaster(obj.sys)
                vendor=soc.internal.getVendor(obj.sys);
                if(strcmpi(vendor,'xilinx')&&~codertarget.internal.isSpPkgInstalled('xilinxsoc'))...
                    ||(strcmpi(vendor,'intel')&&~codertarget.internal.isSpPkgInstalled('intelsoc'))...
                    ||(strcmpi(vendor,'Embedded Linux Board')&&isempty(which('soc.embeddedlinux.internal.getRootDir')))...
                    ||(strcmpi(vendor,'STM32F4-Discovery')&&isempty(which('codertarget.stm32f4discovery.internal.getRootDir')))...
                    ||((strcmpi(vendor,'TI Delfino F28379D LaunchPad')||strcmpi(vendor,'TI Delfino F2837xD'))&&isempty(which('soc.tic2000.internal.getRootFolder')))
                    out=false;
                end
            end

        end
        function savesocsysinfo(obj)
            socsysinfo=obj.socsysinfo;%#ok<PROP>
            save(fullfile(obj.ProjectDir,'socsysinfo.mat'),'socsysinfo');
            if soc.internal.hasProcessor(obj.sys)
                loadProjectInfo(obj.SysDeployer,obj.ProjectDir);
            end
        end























        function eswModel=generateESWSLModel(obj)


            eswModel=generateSoftwareSystem(obj.SysDeployer);
            obj.socsysinfo.projectinfo.sw_system=eswModel;
        end

        function UnusedSwCpuMdls=generateModelsForUnusedCPUs(obj)
            UnusedCPUs=codertarget.utils.getRegisteredCPUs(obj.sys);
            procMdls=obj.ProcessorModel;
            if~iscell(procMdls)
                procMdls={procMdls};
            end

            cpus=cellfun(@(x)codertarget.targethardware.getProcessingUnitName(x),procMdls,'UniformOutput',false);

            UnusedCPUs(contains(UnusedCPUs,cpus))=[];
            UnusedCPUs(contains(UnusedCPUs,'CLA'))=[];
            UnusedSwCpuMdls=cell(1,numel(UnusedCPUs));
            if~isempty(UnusedCPUs)
                if~bdIsLoaded('soc_unused_cpu_top')
                    load_system('soc_unused_cpu_top');
                    topclose=onCleanup(@()close_system('soc_unused_cpu_top',0));
                end
                if~bdIsLoaded('soc_unused_cpu_ref')
                    load_system('soc_unused_cpu_ref');
                    refclose=onCleanup(@()close_system('soc_unused_cpu_ref',0));
                end
            end
            for i=1:numel(UnusedCPUs)
                topMdl=['soc_unused_sw_',UnusedCPUs{i}];
                refMdl=['soc_unused_sw_',UnusedCPUs{i},'_ref'];
                if bdIsLoaded(topMdl)
                    close_system(topMdl,0);
                end
                if bdIsLoaded(refMdl)
                    close_system(refMdl,0);
                end

                disp(message('soc:utils:CreatingSystemModel',topMdl).getString());
                save_system('soc_unused_cpu_top',fullfile(obj.socsysinfo.projectinfo.prj_dir,[topMdl,'.slx']));
                save_system('soc_unused_cpu_ref',fullfile(obj.socsysinfo.projectinfo.prj_dir,[refMdl,'.slx']));


                load_system('soc_unused_cpu_top');
                load_system('soc_unused_cpu_ref');
                disp(message('soc:utils:SystemModel',fullfile(obj.socsysinfo.projectinfo.prj_dir,[topMdl,'.slx'])).getString());

                if~bdIsLoaded(topMdl)
                    load_system(topMdl)
                end
                topswclose=onCleanup(@()close_system(topMdl,0));
                if~bdIsLoaded(refMdl)
                    load_system(refMdl)
                end


                textTopAlign=50;
                textLeftAlign=50;
                genText=sprintf('Software executable model generated from %s by SoC Builder on %s',obj.sys,datestr(now));
                IntroNote=Simulink.Annotation([topMdl,'/',genText]);
                IntroNote.Position=[textLeftAlign,textTopAlign];
                IntroNote.FontSize=12;
                IntroNote.TeXMode='off';

                IntroNoteRef=Simulink.Annotation([refMdl,'/',genText]);
                IntroNoteRef.Position=[textLeftAlign,textTopAlign];
                IntroNoteRef.FontSize=12;
                IntroNoteRef.TeXMode='off';

                refswclose=onCleanup(@()close_system(refMdl,0));

                taskMgrBlk=soc.internal.connectivity.getTaskManagerBlock(topMdl);
                mdlBlk=soc.internal.connectivity.getModelConnectedToTaskManager(taskMgrBlk);
                set_param(mdlBlk,'ModelName',refMdl);
                save_system(topMdl,[],'SaveDirtyReferencedModels','on');


                hwBoard=get_param(obj.sys,'HardwareBoard');
                hwBoardFeatureSet=get_param(obj.sys,'HardwareBoardFeatureSet');
                set_param(topMdl,'HardwareBoard',hwBoard);
                set_param(topMdl,'HardwareBoardFeatureSet',hwBoardFeatureSet);
                codertarget.targethardware.setProcessingUnitName(topMdl,UnusedCPUs{i});

                set_param(refMdl,'HardwareBoard',hwBoard);
                set_param(refMdl,'HardwareBoardFeatureSet',hwBoardFeatureSet);
                codertarget.targethardware.setProcessingUnitName(refMdl,UnusedCPUs{i});

                if~isempty(regexp(hwBoard,'TI Delfino F2837\wD','match','once'))||~isempty(regexp(hwBoard,'TI F2838\wD','match','once'))
                    codertarget.utils.setCPUName(topMdl,UnusedCPUs{i}(end-3:end));
                    codertarget.utils.setCPUName(refMdl,UnusedCPUs{i}(end-3:end));
                    soc.tic2000.internal.setUnusedCPUSettings(refMdl,topMdl,procMdls);
                end

                set_param(refMdl,'ModelReferenceSymbolNameMessage','none');
                set_param(topMdl,'ModelReferenceSymbolNameMessage','none');

                save_system(refMdl);
                save_system(topMdl,[],'SaveDirtyReferencedModels','on');


                if iscell(obj.socsysinfo.projectinfo.sw_system)
                    obj.socsysinfo.projectinfo.sw_system{end+1}=fullfile(obj.socsysinfo.projectinfo.prj_dir,[topMdl,'.slx']);
                else
                    obj.socsysinfo.projectinfo.sw_system=[obj.socsysinfo.projectinfo.sw_system,{fullfile(obj.socsysinfo.projectinfo.prj_dir,[topMdl,'.slx'])}];
                end

                UnusedSwCpuMdls{i}=fullfile(obj.socsysinfo.projectinfo.prj_dir,[topMdl,'.slx']);
                clear('topswclose');
                clear('refswclose');
            end
        end

        function configureModelForExternalModeBuild(obj,swModel)
            cpu=codertarget.targethardware.getProcessingUnitName(swModel);
            ExtInfo=obj.ExtModelInfo(cpu);
            ExtInfo.TopModel=swModel;
            obj.ExtModelInfo(cpu)=ExtInfo;
            if ExtInfo.EnableExtMode

                hCS=getActiveConfigSet(swModel);
                if codertarget.data.isParameterInitialized(hCS,'ExtMode.Configuration')
                    codertarget.data.setParameterValue(hCS,'ExtMode.Configuration',ExtInfo.Interface);
                    data=get_param(hCS,'CoderTargetData');
                    if isfield(data,'ESB')
                        allExtInfo=obj.socsysinfo.projectinfo.ExtModelInfo;
                        allkeys=keys(allExtInfo);
                        otherCPUExtInfo=allkeys(~ismember(allkeys,cpu));
                        if~isempty(otherCPUExtInfo)
                            OtherCPUExtInfo=[];
                            for i=1:numel(otherCPUExtInfo)
                                if(allExtInfo(otherCPUExtInfo{i}).EnableExtMode)
                                    OtherCPUExtInfo.(otherCPUExtInfo{i})=allExtInfo(otherCPUExtInfo{i});
                                end
                            end
                            data.ESB.OtherCPUExtInfo=OtherCPUExtInfo;
                            set_param(hCS,'CoderTargetData',data);
                        end
                    end
                end
                connectionInfoParam=regexprep(ExtInfo.Interface,'\W','');
                if codertarget.data.isParameterInitialized(hCS,['ConnectionInfo.',connectionInfoParam])
                    mdlExtData=codertarget.data.getParameterValue(hCS,['ConnectionInfo.',connectionInfoParam]);
                    if isfield(mdlExtData,'Baudrate')
                        mdlExtData.COMPort=ExtInfo.Connectivity;
                        mdlExtData.Baudrate=ExtInfo.Connectivity1;
                        mdlExtData.Verbose=ExtInfo.Verbose;
                        codertarget.data.setParameterValue(hCS,['ConnectionInfo.',connectionInfoParam],mdlExtData);
                    else
                        if isfield(mdlExtData,'Port')
                            mdlExtData.Address=ExtInfo.Connectivity;
                            mdlExtData.Port=ExtInfo.Connectivity1;
                            mdlExtData.Verbose=ExtInfo.Verbose;
                            codertarget.data.setParameterValue(hCS,['ConnectionInfo.',connectionInfoParam],mdlExtData);
                        end
                    end
                end
            end
        end

        function eswElf=buildESWSLModel(obj)


            eswElf='';
            if~iscell(obj.SysDeployer.SoftwareSystemModel)
                swModels={obj.SysDeployer.SoftwareSystemModel};
            else
                swModels=obj.SysDeployer.SoftwareSystemModel;
            end
            for i=1:numel(swModels)
                if isequal(exist(swModels{i},'file'),4)
                    if isequal(obj.BuildAction,obj.OpenExternalModeModel)
                        configureModelForExternalModeBuild(obj,swModels{i});
                        ExtInfo=obj.ExtModelInfo(codertarget.targethardware.getProcessingUnitName(swModels{i}));
                        eswElfGenPath=obj.buildSoftwareApplication(swModels{i},ExtInfo.EnableExtMode);
                    else
                        eswElfGenPath=obj.buildSoftwareApplication(swModels{i});
                    end
                    [~,fn,fext]=fileparts(eswElfGenPath);
                    eswElfPrjDir=fullfile(obj.ProjectDir,[fn,fext]);

                    copyfile(eswElfGenPath,eswElfPrjDir,'f');
                    if~isfield(obj.socsysinfo.projectinfo,'elf_file')||(i==1)
                        obj.socsysinfo.projectinfo.elf_file=eswElfPrjDir;
                        obj.ESWElf=eswElfPrjDir;
                    else
                        obj.socsysinfo.projectinfo.elf_file=[obj.socsysinfo.projectinfo.elf_file,{eswElfPrjDir}];
                        obj.ESWElf=[obj.ESWElf,{eswElfPrjDir}];
                    end


                    if isequal(get_param(swModels{i},'Dirty'),'on')
                        save_system(swModels{i});
                    end
                end
            end
        end

        function buildModelsForUnusedCPUs(obj,UnusedSwCpuMdls)
            for i=1:numel(UnusedSwCpuMdls)
                swmdl_path=UnusedSwCpuMdls{i};
                if exist(swmdl_path,'file')
                    [fpath,swmdl,ext]=fileparts(swmdl_path);
                    refMdl=[swmdl,'_ref'];

                    if~bdIsLoaded(refMdl)
                        refMdl_path=fullfile(fpath,[refMdl,ext]);
                        if~isequal(exist(refMdl_path,'file'),0)
                            load_system(refMdl_path);
                        else
                            error('Reference model for unused CPU does not exist.');
                        end
                    end

                    if~bdIsLoaded(swmdl)
                        load_system(swmdl_path);
                    end

                    eswElfGenPath=obj.buildSoftwareApplication(swmdl);
                    [~,fn,fext]=fileparts(eswElfGenPath);
                    eswElfPrjDir=fullfile(obj.ProjectDir,[fn,fext]);

                    copyfile(eswElfGenPath,eswElfPrjDir,'f');
                    if~isfield(obj.socsysinfo.projectinfo,'elf_file')
                        obj.socsysinfo.projectinfo.elf_file=eswElfPrjDir;
                        obj.ESWElf=eswElfPrjDir;
                    else
                        obj.socsysinfo.projectinfo.elf_file=[obj.socsysinfo.projectinfo.elf_file,{eswElfPrjDir}];
                        obj.ESWElf=[obj.ESWElf,{eswElfPrjDir}];
                    end
                end
            end
        end

        function openESWSLModelWithExtModeSetting(obj)
            if obj.isModelMultiCPU(obj.sys)
                swMdls=obj.SysDeployer.SoftwareSystemModel;
                if~iscell(swMdls)
                    swMdls={swMdls};
                end
                if obj.LoadExisting




                    socsysinfofile=fullfile(obj.ProjectDir,'socsysinfo.mat');
                    if~isfile(socsysinfofile)
                        error(message('soc:workflow:LoadAndRun_InvalidPrj'));
                    end
                    info=load(socsysinfofile);
                    if isfield(info.socsysinfo.projectinfo,'ExtModelInfo')
                        ExtInfo=info.socsysinfo.projectinfo.ExtModelInfo;
                    else





                        ExtInfo=obj.ExtModelInfo;
                    end
                else
                    ExtInfo=obj.ExtModelInfo;
                end
                for i=1:numel(swMdls)
                    cpuName=codertarget.targethardware.getProcessingUnitName(swMdls{i});
                    ExtModeInfo=ExtInfo(cpuName);
                    if ExtModeInfo.EnableExtMode
                        open_system(fullfile(obj.ProjectDir,swMdls{i}));
                        set_param(swMdls{i},'SimulationMode','External');
                    end
                end
            else
                open_system(fullfile(obj.ProjectDir,obj.SysDeployer.SoftwareSystemModel));
                set_param(obj.SysDeployer.SoftwareSystemModel,'SimulationMode','External');
            end
        end

        function eswDTB=generateDTB(obj)




            eswDTB=generateDeviceTree(obj.SysDeployer);
            savesocsysinfo(obj.SysDeployer);
        end
    end

    methods(Static,Hidden)
        function loadAndRunExecutable(mdlName,exeFile)

            hCS=getActiveConfigSet(mdlName);
            tgtInfo=codertarget.targethardware.getTargetHardware(hCS);
            toolchainInfo=tgtInfo.ToolChainInfo(1);

            soc.internal.SoCGenWorkflow.invokeDownloader(mdlName,hCS,...
            toolchainInfo,exeFile);
        end
        function out=isModelMultiCPU(modelName)
            cs=getActiveConfigSet(modelName);
            out=codertarget.targethardware.hasMultipleProcessingUnits(cs);
        end
        function isProcessorOnly=isModelProcessorOnly(modelName)
            isProcessorOnly=codertarget.utils.isESBProcessorOnly(modelName);

        end

        function eswElf=buildSoftwareApplication(modelName,ForExternalMode)
            if nargin<2
                ForExternalMode=false;
            end
            load_system(modelName);

            oldDirtyFlag=get_param(modelName,'Dirty');
            resetOldDirtyFlag=onCleanup(@()set_param(modelName,'Dirty',oldDirtyFlag));

            if~ForExternalMode
                cset=getActiveConfigSet(modelName);
                oldBuildAction=codertarget.data.getParameterValue(cset,'Runtime.BuildAction');
                resetOldBuildAction=onCleanup(@()codertarget.data.setParameterValue(cset,'Runtime.BuildAction',oldBuildAction));
                codertarget.data.setParameterValue(cset,'Runtime.BuildAction','Build');
            else


                targetHookObj=coder.oneclick.TargetHook.createOneClickTargetHookObject(modelName);
                targetHookObj.configureModelIfNecessary;
                targetHookObj.enableExtMode;
                targetHookObj.preBuild;



                cset=getActiveConfigSet(modelName);
                codertarget.data.setParameterValue(cset,'Runtime.BuildAction','Build');
                resetOldBuildAction=[];%#ok<NASGU>
            end

            rtwbuild(modelName);
            eswElf=fullfile(Simulink.fileGenControl('get','CodeGenFolder'),[modelName,codertarget.tools.getApplicationExtension(modelName)]);

            clear('resetOldBuildAction');
            clear('resetOldDirtyFlag');
        end

        function ret=getESWRefModel(sys)
            taskMgrBlk=soc.internal.connectivity.getTaskManagerBlock(sys,'overrideAssert');
            if isempty(taskMgrBlk)
                ret='';
            else
                if~iscell(taskMgrBlk)
                    ret=soc.internal.SoCGenWorkflow.getReferenceModels(taskMgrBlk);
                else
                    ret=cellfun(@(x)soc.internal.SoCGenWorkflow.getReferenceModels(x),taskMgrBlk,'UniformOutput',false);
                end
            end
        end

        function ret=getReferenceModels(taskMgrBlk)
            connectedBlkHandle=soc.internal.connectivity.getModelConnectedToTaskManager(taskMgrBlk);
            msle=MSLException([],message('soc:utils:TaskMgrConnToSubsys',getfullname(taskMgrBlk),getfullname(connectedBlkHandle)));
            portH=get_param(taskMgrBlk,'LineHandles');
            allLineHandles=portH.Outport;
            allModelRefs=arrayfun(@(x)get_param(get_param(x,'NonVirtualDstPorts'),'Parent'),allLineHandles,'UniformOutput',false);

            areAllModelRefs=cellfun(@(x)isequal(get_param(x,'BlockType'),'ModelReference'),allModelRefs);
            assert(all(areAllModelRefs),'soc:utils:TaskMgrConnToSubsys',msle.message);
            allBlkNames=cellfun(@(x)get_param(x,'ModelName'),allModelRefs,'UniformOutput',false);
            ret=allBlkNames{1};
        end

        function ret=getWorkflowPref(prefName,defaultValueIfNoPref)











            ret=defaultValueIfNoPref;
            if ispref(soc.internal.getPrefName)&&ispref(soc.internal.getPrefName,prefName)
                thisPrefVal=getpref(soc.internal.getPrefName,prefName);
                retvalClass=class(defaultValueIfNoPref);
                if~isempty(thisPrefVal)&&isa(thisPrefVal,retvalClass)

                    ret=thisPrefVal;
                else
                    ret=defaultValueIfNoPref;
                end
            end
        end

        function ret=getFMCIOBlocks(topSys,fpgaSys)






            ret={};
            if isempty(fpgaSys)

                return;
            end
            supportedIOBlks={'xilinxsocad9361lib/AD9361*',...
            'xilinxsocvisionlib/HDMI Rx',...
            'xilinxrfsoclib/RF Data Converter'};
            for ii=1:numel(supportedIOBlks)
                thisIOBlkPattern=supportedIOBlks{ii};


                ioBlks=find_system(topSys,'Regexp','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'ReferenceBlock',thisIOBlkPattern);
                if isempty(ioBlks)
                    ioBlks=find_system(fpgaSys,'Regexp','on',...
                    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                    'ReferenceBlock',thisIOBlkPattern);
                end
                if isempty(ioBlks)
                    continue;
                else
                    ret=ioBlks;
                    break;
                end
            end
        end

        function programsoc(projectFolder)
            socsysinfofile=fullfile(projectFolder,'socsysinfo.mat');
            if~isfile(socsysinfofile)
                error(message('soc:workflow:LoadAndRun_InvalidPrj'));
            end
            info=load(socsysinfofile);
            sysinfo=info.socsysinfo;
            bit_file=sysinfo.projectinfo.bit_file;
            [~,fileName,ext]=fileparts(bit_file);
            bit_file=fullfile(projectFolder,[fileName,ext]);
            mdlName=sysinfo.modelinfo.sys;
            hasProcessor=soc.internal.hasProcessor(mdlName);
            if(strcmpi(sysinfo.projectinfo.vendor,'xilinx')||~hasProcessor)&&~exist(bit_file,'file')
                error(message('soc:workflow:LoadAndRun_InvalidPrj'));
            elseif strcmpi(sysinfo.projectinfo.vendor,'intel')&&hasProcessor
                [fPath,fName]=fileparts(bit_file);
                if strcmpi(sysinfo.projectinfo.fullboardname,'Altera Arria 10 SoC development kit')
                    coreFile=fullfile(fPath,[fName,'.core.rbf']);
                    perphFile=fullfile(fPath,[fName,'.periph.rbf']);
                elseif strcmpi(sysinfo.projectinfo.fullboardname,'Altera Cyclone V SoC development kit')
                    coreFile=fullfile(fPath,[fName,'.rbf']);
                    perphFile='';
                else
                    coreFile='';
                    perphFile='';
                end
                if(~isempty(coreFile)&&~exist(coreFile,'file'))||(~isempty(perphFile)&&~exist(perphFile,'file'))
                    error(message('soc:workflow:LoadAndRun_InvalidPrj'));
                end
            end
            hwBoard=get_param(mdlName,'HardwareBoard');
            if hasProcessor

                hwObj=createHardwareObject(hwBoard);

                sysinfo.projectinfo.prj_dir=projectFolder;
                if~soc.internal.isCustomHWBoard(hwBoard)
                    deviceTreeGenObj=soc.if.CustomDeviceTreeUpdater.getInstance(sysinfo,'HardwareObject',hwObj);
                else
                    deviceTreeGenObj=soc.if.CustomDeviceTreeUpdater.getInstance(...
                    sysinfo,'HardwareObject',hwObj,'IsCustomBoard',1);
                end
                dtbFile=generateDeviceTree(deviceTreeGenObj);
                sysinfo.projectinfo.dtb_file=dtbFile;
                dtb_file=sysinfo.projectinfo.dtb_file;
                soc.internal.SoCGenWorkflow.runPreProgramSoCFcn(sysinfo);

                if~soc.internal.isCustomHWBoard(hwBoard)
                    loadBitstream(hwObj,bit_file,dtb_file);
                else
                    soc.internal.SoCGenWorkflow.invokeDeployer(mdlName,false,bit_file,dtb_file);
                end
                soc.internal.SoCGenWorkflow.runPostProgramSoCFcn(sysinfo);
            else
                jtagChainPosition=soc.internal.getJTAGChainPosition(hwBoard);
                if strcmpi(sysinfo.projectinfo.vendor,'xilinx')
                    soc.internal.programFPGA('Xilinx',bit_file,jtagChainPosition);
                else
                    soc.internal.programFPGA('Altera',bit_file,jtagChainPosition);
                end
            end
        end

        function runPreProgramSoCFcn(sysinfo)
            if isfield(sysinfo.ipcoreinfo,'customipcore_info')&&~isempty(sysinfo.ipcoreinfo.customipcore_info)
                customipinfo=sysinfo.ipcoreinfo.customipcore_info;
                if isfield(customipinfo,'PreProgramSoCFcn')&&~isempty(customipinfo.PreProgramSoCFcn)...
                    &&isfile(which(customipinfo.PreProgramSoCFcn))
                    mdlName=sysinfo.modelinfo.sys;
                    hwBoard=get_param(mdlName,'HardwareBoard');
                    hwObj=createHardwareObject(hwBoard);
                    feval(customipinfo.PreProgramSoCFcn,hwObj,customipinfo.PreProgramSoCFcnArgs);
                else

                end
            else

            end
        end

        function runPostProgramSoCFcn(sysinfo)
            if isfield(sysinfo.ipcoreinfo,'customipcore_info')&&~isempty(sysinfo.ipcoreinfo.customipcore_info)
                customipinfo=sysinfo.ipcoreinfo.customipcore_info;
                if isfield(customipinfo,'PostProgramSoCFcn')&&~isempty(customipinfo.PostProgramSoCFcn)...
                    &&isfile(which(customipinfo.PostProgramSoCFcn))
                    mdlName=sysinfo.modelinfo.sys;
                    hwBoard=get_param(mdlName,'HardwareBoard');
                    hwObj=createHardwareObject(hwBoard);
                    feval(customipinfo.PostProgramSoCFcn,hwObj,customipinfo.PostProgramSoCFcnArgs);
                else

                end
            else

            end
        end

        function runsoftwareapp(projectFolder)
            socsysinfofile=fullfile(projectFolder,'socsysinfo.mat');
            if~isfile(socsysinfofile)
                error(message('soc:workflow:LoadAndRun_InvalidPrj'));
            end
            info=load(socsysinfofile);
            sysinfo=info.socsysinfo;

            if isfield(sysinfo.projectinfo,'elf_file')
                elfFile=sysinfo.projectinfo.elf_file;
                if~iscell(elfFile)
                    elfFile={elfFile};
                end
                for i=1:numel(elfFile)
                    [~,fileName,ext]=fileparts(elfFile{i});
                    elfFile{i}=fullfile(projectFolder,[fileName,ext]);
                    if~isfile(elfFile{i})
                        error(message('soc:workflow:LoadAndRun_InvalidPrj'));
                    end
                end
            else
                error(message('soc:workflow:LoadAndRun_InvalidPrj'));
            end
            mdlName=sysinfo.modelinfo.sys;
            hwBoard=get_param(mdlName,'HardwareBoard');
            if~soc.internal.SoCGenWorkflow.isModelProcessorOnly(mdlName)
                for i=1:numel(elfFile)
                    if~soc.internal.isCustomHWBoard(hwBoard)

                        hwObj=createHardwareObject(hwBoard);
                        [~,fName,fext]=fileparts(elfFile{i});
                        remotePath=['/tmp/',fName,fext];
                        try
                            system(hwObj,['pkill -9 ',fName,fext]);
                        catch ME %#ok<NASGU>

                        end
                        putFile(hwObj,elfFile{i},remotePath);
                        system(hwObj,['chmod go+x ',remotePath]);
                        cmd=['export DISPLAY=:0.0; export XAUTHORITY=~/.Xauthority; '...
                        ,remotePath,' &> ',remotePath,'.log &'];
                        system(hwObj,cmd);
                    else
                        soc.internal.SoCGenWorkflow.loadAndRunExecutable(mdlName,elfFile{i});
                    end
                end
            else
                if~soc.internal.SoCGenWorkflow.isModelMultiCPU(mdlName)
                    soc.internal.SoCGenWorkflow.loadAndRunExecutable(mdlName,elfFile{1});
                else
                    for i=1:numel(elfFile)
                        exeFile=elfFile{i};
                        [fpath,ename,~]=fileparts(exeFile);
                        swmdl=fullfile(fpath,[ename,'.slx']);
                        switch exist(swmdl,'file')
                        case 2
                            load_system(swmdl);
                            hCS=getActiveConfigSet(ename);
                        case 4
                            hCS=getActiveConfigSet(ename);
                        otherwise
                            error(message('soc:utils:NoSoftwareModel',exeFile,ename));
                        end

                        puInfo=codertarget.targethardware.getProcessingUnitInfo(hCS);
                        if~isempty(puInfo)
                            toolchainInfo=puInfo.ToolChainInfo(1);
                        else
                            tgtInfo=codertarget.targethardware.getTargetHardware(hCS);
                            toolchainInfo=tgtInfo.ToolChainInfo(1);
                        end

                        soc.internal.SoCGenWorkflow.invokeDownloader(mdlName,hCS,...
                        toolchainInfo,elfFile{i});
                    end
                end
            end
        end

        function invokeDeployer(mdlName,isPureFPGA,bit_file,dtb_file)
            boardSupportName=codertarget.target.getTargetName(mdlName);
            boardSupportObj=soc.sdk.loadBoardSupport(boardSupportName);
            deployerObj=getDeployer(boardSupportObj,'mapped');
            loadCommand=deployerObj{1}.BitstreamLoaders{1}.LoadCommand;
            boardName=get_param(mdlName,'HardwareBoard');
            if startsWith(loadCommand,'matlab:')
                loadCommand=loadCommand(8:end);
            else
                error(message('soc_shared:msgs:InvalidLoadCommand'));
            end
            if isPureFPGA
                jtagChainPosition=soc.internal.getJTAGChainPosition(boardName);
                vendor=soc.internal.getVendor(mdlName);
                feval(loadCommand,boardName,vendor,isPureFPGA,bit_file,'',jtagChainPosition)
            else
                feval(loadCommand,boardName,'',isPureFPGA,bit_file,dtb_file,'')
            end
        end

        function tcName=getDefaultToolchainName
            mexCompInfoDefault=rtwprivate('getMexCompilerInfo');
            tcName=coder.make.internal.getToolchainNameFromRegistry...
            (mexCompInfoDefault.compStr);
        end

        function invokeDownloader(modelName,hCS,toolchainInfo,exeFile)
            disp(message('soc:utils:LoadSoftwareModel',exeFile).getString());
            toolchainName=get_param(hCS,'Toolchain');
            if isequal(toolchainName,coder.make.internal.getInfo('default-toolchain'))
                toolchainName=soc.customboard.ui.SoCGenWorkflow.getDefaultToolchainName;
            end

            if codertarget.utils.isESBEnabled(modelName)

                soc.internal.customoperatingsystem.isCompatible(modelName);
            end

            toolchain=coder.make.internal.getToolchainInfoFromRegistry(toolchainName);
            try
                useToolchainToDownload=~toolchainInfo.IsLoadCommandMATLABFcn...
                &&toolchain.PostbuildTools.isKey('Download');
                if~useToolchainToDownload
                    loadCommand=toolchainInfo.LoadCommand;
                    try


                        arguments=eval(toolchainInfo.LoadCommandArgs);
                    catch e %#ok<NASGU>
                        arguments=toolchainInfo.LoadCommandArgs;
                    end
                    hardwareName=codertarget.data.getParameterValue(hCS,'TargetHardware');
                    if toolchainInfo.IsLoadCommandMATLABFcn
                        feval(loadCommand,arguments,exeFile,hardwareName,hCS);
                    else
                        system(loadCommand,arguments,exeFile,hardwareName);
                    end

                end
            catch e
                error('codertarget:build:DownloadCallbackError',char([10,e.message]));
            end
        end
    end

    methods(Hidden)
        function setHWObj(obj,hwObj)
            obj.SysDeployer.HWObj=hwObj;
        end
    end
end







