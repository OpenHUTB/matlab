classdef LoadAndRun<soc.ui.TemplateBaseWithSteps




    properties
Description
Load
ProgressInfo
    end

    properties(Hidden,Dependent)
BitFile
Vendor
ReportFile
Board
JTAGFile
BuildAction
ProjectDir
HasReferenceDesign
DUTFullPath
    end

    methods
        function this=LoadAndRun(varargin)
            this@soc.ui.TemplateBaseWithSteps(varargin{:});


            this.Description=matlab.hwmgr.internal.hwsetup.Label.getInstance(this.ContentPanel);
            this.Load=matlab.hwmgr.internal.hwsetup.Button.getInstance(this.ContentPanel);
            this.ProgressInfo=matlab.hwmgr.internal.hwsetup.StatusTable.getInstance(this.ContentPanel);


            this.setCurrentStep(4);
            if strcmpi(this.Workflow.ModelType,this.Workflow.FpgaOnly)
                this.Title.Text=message('soc:workflow:LoadAndRun_Title_FPGA').getString();
            else
                this.Title.Text=message('soc:workflow:LoadAndRun_Title').getString();
            end

            if this.BuildAction==1
                actionStr='buildrun';
            elseif this.BuildAction==2
                actionStr='buildonly';
            elseif this.BuildAction==3
                actionStr='extmode';
            else
                error(message('soc:workflow:UndefinedBuildAction'));
            end

            typeActionStr=lower([this.Workflow.ModelType,'_',actionStr]);
            if(this.BuildAction==3)&&this.Workflow.isModelProcessorOnly(this.Workflow.sys)
                this.Description.Text=message(['soc:workflow:LoadAndRun_LoadInstruction_',typeActionStr,'_proc']).getString();
            else
                this.Description.Text=message(['soc:workflow:LoadAndRun_LoadInstruction_',typeActionStr]).getString();
            end
            this.Description.shiftVertically(250);
            this.Description.addWidth(350);
            this.Description.addHeight(35);

            this.ProgressInfo.Status={''};
            this.ProgressInfo.Steps={''};
            this.ProgressInfo.Border='off';

            if strcmpi(this.Workflow.ModelType,this.Workflow.FpgaOnly)
                this.Load.Text=message('soc:workflow:LoadAndRun_Button_Load').getString();
            else
                if this.Workflow.isModelProcessorOnly(this.Workflow.sys)
                    this.Load.Text=message('soc:workflow:LoadAndRun_Button_LoadAndRun').getString();
                else
                    if this.BuildAction==this.Workflow.OpenExternalModeModel
                        this.Load.Text=message('soc:workflow:LoadAndRun_Button_Load').getString();
                    else
                        this.Load.Text=message('soc:workflow:LoadAndRun_Button_LoadAndRun').getString();
                    end
                end
            end
            this.Load.Position=[350,250,100,22];
            this.Load.Color=matlab.hwmgr.internal.hwsetup.util.Color.MWBLUE;
            this.Load.FontColor=matlab.hwmgr.internal.hwsetup.util.Color.WHITE;
            this.Load.ButtonPushedFcn=@this.LoadAndRunCB;

            if this.BuildAction==2
                this.Load.Visible='off';
            end

            if this.BuildAction==2
                if this.HasReferenceDesign
                    this.ProgressInfo.Steps{1}=[...
'<br/><br/>'...
                    ,message('soc:workflow:LoadAndRun_BuildOnly_Referencedesign').getString()
                    ];
                else
                    if ispc
                        msgid='soc:workflow:LoadAndRun_Report';
                    else
                        msgid='soc:workflow:LoadAndRun_Report_Linux';
                    end
                    this.ProgressInfo.Steps{1}=[...
'<br/><br/>'...
                    ,message(msgid,this.ReportFile,this.ProjectDir).getString()
                    ];
                end
            else
                this.ProgressInfo.Steps{1}='<br/>';
            end
            this.ProgressInfo.Position=[10,180,300,100];

            if~this.Workflow.isModelProcessorOnly(this.Workflow.sys)
                this.HelpText.WhatToConsider=message('soc:workflow:LoadAndRun_WhatToConsider').getString();
            else
                this.HelpText.WhatToConsider=message('soc:workflow:LoadAndRun_WhatToConsider_proc').getString();
            end

            if this.Workflow.isModelProcessorOnly(this.Workflow.sys)&&isequal(this.Workflow.BuildAction,this.Workflow.OpenExternalModeModel)
                this.HelpText.AboutSelection=message('soc:workflow:LoadAndRun_AboutSelection').getString();
            else
                this.HelpText.AboutSelection='';
            end

            if this.BuildAction~=2
                this.NextButton.Enable='off';
            end
        end

        function screen=getPreviousScreenID(this)
            if this.Workflow.LoadExisting
                if strcmpi(this.Workflow.ModelType,this.Workflow.FpgaOnly)
                    if soc.internal.hasProcessor(this.Workflow.sys)||...
                        (this.Workflow.HasReferenceDesign&&this.Workflow.ReferenceDesignInfo.HasProcessingSystem)
                        screen='soc.ui.ConnectHardware';
                    else
                        screen='soc.ui.SelectProjectFolder';
                    end

                else
                    if~this.Workflow.isModelProcessorOnly(this.Workflow.sys)
                        screen='soc.ui.ConnectHardware';
                    else
                        screen='soc.ui.SelectProjectFolder';
                    end
                end
            else
                if(this.Workflow.BuildAction==2)

                    screen='soc.ui.BuildModel';
                elseif strcmpi(this.Workflow.ModelType,this.Workflow.FpgaOnly)
                    if soc.internal.hasProcessor(this.Workflow.sys)||...
                        (this.Workflow.HasReferenceDesign&&this.Workflow.ReferenceDesignInfo.HasProcessingSystem)


                        screen='soc.ui.ConnectHardware';
                    else

                        screen='soc.ui.BuildModel';
                    end
                else
                    if~this.Workflow.isModelProcessorOnly(this.Workflow.sys)

                        screen='soc.ui.ConnectHardware';
                    else
                        screen='soc.ui.BuildModel';
                    end
                end
            end
        end

        function result=get.BitFile(this)
            load(fullfile(this.Workflow.ProjectDir,'socsysinfo.mat'),'socsysinfo');
            result=socsysinfo.projectinfo.bit_file;
            if this.Workflow.LoadExisting
                [~,fileName,ext]=fileparts(result);
                result=fullfile(this.Workflow.ProjectDir,[fileName,ext]);
            end
        end
        function result=get.Vendor(this)
            load(fullfile(this.Workflow.ProjectDir,'socsysinfo.mat'),'socsysinfo');
            result=socsysinfo.projectinfo.vendor;
        end
        function result=get.ReportFile(this)
            load(fullfile(this.Workflow.ProjectDir,'socsysinfo.mat'),'socsysinfo');
            result=socsysinfo.projectinfo.report;
            if this.Workflow.LoadExisting
                [~,fileName,ext]=fileparts(result);
                result=fullfile(this.Workflow.ProjectDir,'html',[fileName,ext]);
            end
        end
        function result=get.Board(this)
            load(fullfile(this.Workflow.ProjectDir,'socsysinfo.mat'),'socsysinfo');
            result=socsysinfo.projectinfo.fullboardname;
        end
        function result=get.JTAGFile(this)
            load(fullfile(this.Workflow.ProjectDir,'socsysinfo.mat'),'socsysinfo');
            if isfield(socsysinfo.projectinfo,'jtag_file')
                result=socsysinfo.projectinfo.jtag_file;
                if this.Workflow.LoadExisting
                    [~,fileName,ext]=fileparts(result);
                    result=fullfile(this.Workflow.ProjectDir,[fileName,ext]);
                end
            else
                result='';
            end
        end
        function result=get.BuildAction(this)
            if this.Workflow.LoadExisting
                load(fullfile(this.Workflow.ProjectDir,'socsysinfo.mat'),'socsysinfo');
                result=socsysinfo.projectinfo.build_action;
                if result==2
                    result=1;
                end
            else
                result=this.Workflow.BuildAction;
            end
        end
        function result=get.ProjectDir(this)
            result=this.Workflow.ProjectDir;
        end
        function result=get.HasReferenceDesign(this)
            load(fullfile(this.Workflow.ProjectDir,'socsysinfo.mat'),'socsysinfo');
            if isfield(socsysinfo.modelinfo,'hasReferenceDesign')
                result=socsysinfo.modelinfo.hasReferenceDesign;
            else
                result=false;
            end
        end
        function result=get.DUTFullPath(this)
            load(fullfile(this.Workflow.ProjectDir,'socsysinfo.mat'),'socsysinfo');
            result=socsysinfo.ipcoreinfo.mwipcore_info.blk_name;
        end
    end

    methods(Access=private)
        function LoadAndRunCB(this,~,~)
            this.NextButton.Enable='off';
            this.Load.Enable='off';
            statusIcon=matlab.hwmgr.internal.hwsetup.StatusIcon(5);
            progressIcon=statusIcon.dispIcon();
            progressText=message('soc:workflow:LoadAndRun_LoadProgress_LoadingDesign').getString();
            this.ProgressInfo.Steps{1}=[progressIcon,'&nbsp;&nbsp;',progressText];
            try
                if~this.HasReferenceDesign

                    if this.Workflow.HasFPGA
                        if(strcmpi(this.Vendor,'xilinx')||~soc.internal.hasProcessor(this.Workflow.sys))&&~exist(this.BitFile,'file')
                            error(message('soc:workflow:LoadAndRun_BitFileNotFound',this.BitFile).getString());
                        elseif strcmpi(this.Vendor,'intel')&&soc.internal.hasProcessor(this.Workflow.sys)
                            [fPath,fName]=fileparts(this.BitFile);
                            if strcmpi(this.Board,'Altera Arria 10 SoC development kit')
                                coreFile=fullfile(fPath,[fName,'.core.rbf']);
                                perphFile=fullfile(fPath,[fName,'.periph.rbf']);
                                if~exist(perphFile,'file')
                                    error(message('soc:workflow:LoadAndRun_BitFileNotFound',perphFile).getString());
                                end
                            elseif strcmpi(this.Board,'Altera Cyclone V SoC development kit')
                                coreFile=fullfile(fPath,[fName,'.rbf']);
                            else
                                coreFile='';
                            end
                            if~isempty(coreFile)&&~exist(coreFile,'file')
                                error(message('soc:workflow:LoadAndRun_BitFileNotFound',coreFile).getString());
                            end
                        end
                    end
                else


                    supportedVersion=this.Workflow.ReferenceDesignInfo.SupportedToolVersion{1};
                    soc.internal.validateToolVersion(this.Vendor,supportedVersion);





                    shippingRDBrdList={'Xilinx Zynq UltraScale+ RFSoC ZCU111 Evaluation Kit',...
                    'Xilinx Zynq UltraScale+ RFSoC ZCU216 Evaluation Kit'};
                    shippingRDList={'Real ADC/DAC Interface',...
                    'Real ADC/DAC Interface with PL-DDR4',...
                    'IQ ADC/DAC Interface',...
                    'IQ ADC/DAC Interface with PL-DDR4'};
                    if isequal(this.Workflow.ModelType,this.Workflow.SocFpga)||...
                        (any(strcmp(this.Workflow.ReferenceDesignInfo.RDBoardName,shippingRDBrdList))&&...
                        any(strcmp(this.Workflow.ReferenceDesignInfo.RDName,shippingRDList)))
                        zynqLinuxBinaries3pDir=matlab.internal.get3pInstallLocation('zynqlinuxbinaries_soc.instrset');
                        if~isfolder(zynqLinuxBinaries3pDir)
                            error(message('zynq:utils:AllTpToolsNotInstalled'));
                        end
                    end
                end


                if strcmpi(this.Workflow.ModelType,this.Workflow.FpgaOnly)
                    if this.HasReferenceDesign
                        soc.internal.programUsingHDLWACLI(this.DUTFullPath,this.ProjectDir);
                    else
                        if soc.internal.hasProcessor(this.Workflow.sys)
                            this.Workflow.programsoc(this.ProjectDir);
                        else
                            if~soc.internal.isCustomHWBoard(this.Board)
                                jtagChainPosition=soc.internal.getJTAGChainPosition(this.Board);
                                if strcmpi(this.Vendor,'xilinx')
                                    soc.internal.programFPGA('Xilinx',this.BitFile,jtagChainPosition);
                                else
                                    soc.internal.programFPGA('Intel',this.BitFile,jtagChainPosition);
                                end
                            else
                                soc.ui.SoCGenWorkflow.invokeDeployer(this.Workflow.sys,true,this.BitFile,'');
                            end
                        end
                        progressText=message('soc:workflow:LoadAndRun_Success_fpga').getString();
                        if~isempty(this.JTAGFile)
                            progressText=[progressText,'&nbsp;'...
                            ,message('soc:workflow:LoadAndRun_ShowJTAGFile',this.JTAGFile).getString()];
                        end
                    end
                elseif isequal(this.Workflow.ModelType,this.Workflow.SocFpga)
                    if this.HasReferenceDesign
                        soc.internal.programUsingHDLWACLI(this.DUTFullPath,this.ProjectDir);
                    else
                        this.Workflow.programsoc(this.ProjectDir);
                    end
                    if isequal(this.BuildAction,3)
                        openESWSLModelWithExtModeSetting(this.Workflow);
                        progressText=message('soc:workflow:LoadAndRun_Success_soc_external',fullfile(this.ProjectDir,[this.Workflow.SysDeployer.SoftwareSystemModel,'.slx'])).getString();
                    else
                        this.Workflow.runsoftwareapp(this.ProjectDir);
                        progressText=message('soc:workflow:LoadAndRun_Success_soc_build').getString();
                    end
                    indx=logical([soc.internal.hasAPM(this.Workflow.sys),soc.internal.hasATG(this.Workflow.sys)]);
                    if~isempty(this.JTAGFile)&&any(indx)
                        progressText=[progressText,'&nbsp;'...
                        ,message('soc:workflow:LoadAndRun_ShowJTAGFile_soc',this.JTAGFile).getString()];
                    end
                else
                    if isequal(this.BuildAction,this.Workflow.OpenExternalModeModel)
                        if~this.Workflow.isModelMultiCPU(this.Workflow.sys)


                            if this.Workflow.isModelProcessorOnly(this.Workflow.sys)


                                openESWSLModelWithExtModeSetting(this.Workflow);
                            else
                                set_param(this.Workflow.sys,'SimulationMode','External');
                                soc.internal.taskmanager.syncSchedules(this.Workflow.sys,false);
                                open_system(this.Workflow.sys);
                            end
                            progressText=message('soc:workflow:LoadAndRun_Success_arm_external',this.Workflow.sys).getString();
                        else
                            this.Workflow.runsoftwareapp(this.ProjectDir);
                            openESWSLModelWithExtModeSetting(this.Workflow);



                            if isequal(this.Workflow.LoadExisting,true)
                                socsysinfofile=fullfile(this.ProjectDir,'socsysinfo.mat');
                                if~isfile(socsysinfofile)
                                    error(message('soc:workflow:LoadAndRun_InvalidPrj'));
                                end
                                info=load(socsysinfofile);
                                if isfield(info.socsysinfo.projectinfo,'ExtModelInfo')
                                    ExtInfo=info.socsysinfo.projectinfo.ExtModelInfo;
                                else
                                    ExtInfo=this.Workflow.ExtModelInfo;
                                end
                            else
                                ExtInfo=this.Workflow.ExtModelInfo;
                            end




                            keys=ExtInfo.keys;
                            for i=1:numel(keys)
                                tmp=ExtInfo(keys{i});
                                if tmp.EnableExtMode



                                    sl_refresh_customizations;
                                    set_param(tmp.TopModel,'SimulationCommand','connect');
                                    set_param(tmp.TopModel,'SimulationCommand','start');
                                end
                            end
                        end
                    else
                        this.Workflow.runsoftwareapp(this.ProjectDir);
                        progressText=message('soc:workflow:LoadAndRun_Success_arm_build').getString();
                    end
                end


                statusIcon=matlab.hwmgr.internal.hwsetup.StatusIcon(1);
                progressIcon=statusIcon.dispIcon();
                if ispc
                    msgid='soc:workflow:LoadAndRun_Report';
                else
                    msgid='soc:workflow:LoadAndRun_Report_Linux';
                end
                if this.Workflow.HasReferenceDesign
                    progressText=message('soc:workflow:LoadAndRun_Success_referencedesign').getString();
                else
                    progressText=[progressText...
                    ,'<br/><br/>'...
                    ,message(msgid,this.ReportFile,this.ProjectDir).getString()];
                end
                this.ProgressInfo.Steps{1}=[progressIcon,'&nbsp;&nbsp;',progressText];
                this.NextButton.Enable='on';
                this.Load.Enable='on';
            catch ME
                statusIcon=matlab.hwmgr.internal.hwsetup.StatusIcon(0);
                progressIcon=statusIcon.dispIcon();
                this.ProgressInfo.Steps{1}=[progressIcon,'&nbsp;&nbsp;',ME.message];
                this.Load.Enable='on';
            end
        end
    end
end


